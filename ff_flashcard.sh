#!/bin/bash
#
# ff_flashcard.sh - Create Anki flashcard via Claude Code (multi-language)
#
# Automatically routes to vocabulary (single word) or meaningblock (phrase) workflow
# based on the number of space-separated tokens in the input.
#
# Usage: ./ff_flashcard.sh --lang=fr "word or phrase"
#        ./ff_flashcard.sh --lang=sv "word or phrase"
#        echo "word or phrase" | ./ff_flashcard.sh --lang=fr
#
# Supported languages:
#   fr - French
#   sv - Swedish
#
# Exit codes:
#   0 - Success
#   1 - Missing input or invalid arguments
#   2 - Anki not running
#   3 - AnkiConnect not responsive
#   4 - Claude invocation failed
#   5 - Language configuration not found

# Ensure PATH includes Homebrew and local bin (needed when run from macOS Services)
export PATH="/opt/homebrew/bin:${HOME}/.local/bin:${PATH}"

# Get the script's directory (for finding config files)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to project directory (needed for Claude to find slash commands and MCP config)
cd "$SCRIPT_DIR" || exit 1

# Debug logging - preserve original stdout/stderr for console output
exec 3>&1 4>&2  # Save original stdout (3) and stderr (4)
exec >> /tmp/flashcard.log 2>&1
echo "=== $(date) ==="
echo "PATH: $PATH"
echo "PWD: $PWD"
echo "Args: $*"

set -euo pipefail

# Log to file only (verbose debug info)
log() {
    echo "$*"
}

# Log to both file AND console (important user-facing info)
info() {
    echo "$*"
    echo "$*" >&3 2>/dev/null || true
}

# Configuration
readonly ANKI_CONNECT_URL="http://localhost:8765"
readonly ANKI_CONNECT_TIMEOUT=3
readonly CLAUDE_PATH="${HOME}/.local/bin/claude"
readonly NOTIFIER_PATH="/opt/homebrew/bin/terminal-notifier"

# Language configuration (set after parsing arguments)
LANG_CODE=""
LANG_NAME=""
LANG_TTS_CODE=""
LANG_VOICE_ID=""
LANG_DECK_PREFIX=""
LANG_REFERENCE=""
LANG_REFERENCE_URL=""

# Print usage information
usage() {
    echo "Usage: $0 --lang=<code> <word or phrase>"
    echo "       $0 --lang=<code> < input.txt"
    echo ""
    echo "Supported language codes:"
    echo "  fr - French"
    echo "  sv - Swedish"
    echo ""
    echo "Examples:"
    echo "  $0 --lang=fr \"bonjour\""
    echo "  $0 --lang=sv \"hej\""
    echo "  echo \"au revoir\" | $0 --lang=fr"
    exit 1
}

# Load language configuration
load_language_config() {
    local lang_code="$1"
    local config_file="${SCRIPT_DIR}/config/languages/${lang_code}.conf"

    if [[ ! -f "$config_file" ]]; then
        echo "ERROR: Language configuration not found: $config_file" >&2
        echo "Available languages:" >&2
        ls -1 "${SCRIPT_DIR}/config/languages/"*.conf 2>/dev/null | xargs -I {} basename {} .conf | sed 's/^/  /' >&2
        exit 5
    fi

    # shellcheck source=/dev/null
    source "$config_file"

    echo "Loaded language configuration: $LANG_NAME ($LANG_CODE)" >&2
}

# Notification helper - sends to console, log, AND macOS notification center
# Usage: notify "title" "message" [sound] [no_group]
#   sound: "default", "Glass", "Basso", or "" for silent
#   no_group: if set to "no_group", notification won't replace previous ones
notify() {
    local title="$1"
    local message="$2"
    local sound="${3:-}"
    local no_group="${4:-}"

    # Log output (goes to log file via exec redirect)
    if [[ "$title" == *"Error"* ]] || [[ "$title" == *"Failed"* ]]; then
        echo "ERROR: $message" >&2
        # Also write to original stderr (console) if available
        echo "ERROR: $message" >&4 2>/dev/null || true
    else
        echo "$message"
        # Also write to original stdout (console) if available
        echo "$message" >&3 2>/dev/null || true
    fi

    # macOS notification via terminal-notifier (use absolute path for Services compatibility)
    if [[ -x "$NOTIFIER_PATH" ]]; then
        local -a args=(
            -title "Anki ${LANG_NAME} Card"
            -subtitle "$title"
            -message "$message"
        )

        # Add sound if specified
        if [[ -n "$sound" ]]; then
            args+=(-sound "$sound")
        fi

        # Use group to replace notifications (progress updates) unless no_group specified
        if [[ "$no_group" != "no_group" ]]; then
            args+=(-group "anki-${LANG_CODE}-flashcard")
        fi

        "$NOTIFIER_PATH" "${args[@]}" 2>/dev/null || true
    else
        # Fallback to native AppleScript notification
        osascript -e "display notification \"$message\" with title \"Anki ${LANG_NAME} Card\" subtitle \"$title\"" 2>/dev/null || true
    fi
}

# Pre-flight check: Anki application running
# Note: Anki may run as a Python process, so we check for both the app bundle
# and the Python process that runs aqt (Anki's Qt interface)
check_anki_running() {
    if pgrep -x Anki > /dev/null 2>&1; then
        info "✓ Anki is running"
        return 0
    fi

    # Check for Anki running via Python (common with some installations)
    if pgrep -f "aqt.run" > /dev/null 2>&1; then
        info "✓ Anki is running (via Python)"
        return 0
    fi

    notify "Error" "Anki is not running. Please start Anki first." "Basso"
    exit 2
}

# Pre-flight check: AnkiConnect addon responsive
check_anki_connect() {
    local response

    response=$(curl -s --connect-timeout "$ANKI_CONNECT_TIMEOUT" \
        -X POST "$ANKI_CONNECT_URL" \
        -d '{"action": "version", "version": 6}' 2>/dev/null) || {
        notify "Error" "AnkiConnect not responding. Is the AnkiConnect addon installed?" "Basso"
        exit 3
    }

    # Verify valid response (should contain "result")
    if ! echo "$response" | grep -q '"result"'; then
        notify "Error" "AnkiConnect returned invalid response: $response" "Basso"
        exit 3
    fi

    info "✓ AnkiConnect is responsive"
}

# Get input from remaining arguments or stdin
get_input() {
    local input=""

    # From arguments (after language flag has been removed)
    if [[ $# -gt 0 ]]; then
        input="$*"
    # From stdin (pipe or redirect)
    elif [[ ! -t 0 ]]; then
        input=$(cat)
    fi

    # Trim leading/trailing whitespace
    input=$(echo "$input" | xargs)

    if [[ -z "$input" ]]; then
        notify "Error" "No input provided. Usage: $0 --lang=<code> <word or phrase>" "Basso"
        exit 1
    fi

    echo "$input"
}

# Count space-separated tokens in input
# Note: Hyphenated words like "c'est-à-dire" count as one token
count_words() {
    local input="$1"
    # Use wc -w to count words (space-separated tokens)
    echo "$input" | wc -w | tr -d ' '
}

# Main execution
main() {
    # Must have at least one argument
    if [[ $# -lt 1 ]]; then
        usage
    fi

    # Parse language argument
    local lang_arg=""
    if [[ "$1" =~ ^--lang=(.+)$ ]]; then
        lang_arg="${BASH_REMATCH[1]}"
        shift
    else
        echo "ERROR: First argument must be --lang=<code>" >&2
        usage
    fi

    # Validate language code (2 letters)
    if [[ ! "$lang_arg" =~ ^[a-z]{2}$ ]]; then
        echo "ERROR: Language code must be 2 lowercase letters (e.g., fr, sv)" >&2
        usage
    fi

    # Load language configuration (in main shell, not subshell)
    load_language_config "$lang_arg"

    # Get remaining args
    local remaining_args="$*"

    # Get input text
    local input
    input=$(get_input $remaining_args)

    local word_count
    word_count=$(count_words "$input")

    info "Language: $LANG_NAME ($LANG_CODE)"
    info "Input: $input"
    log "Word count: $word_count"
    log "---"

    # Pre-flight checks
    check_anki_running
    check_anki_connect

    log "---"
    info "Invoking Claude Code..."

    # Determine which slash command to use based on word count
    local slash_command
    local card_type

    if [[ "$word_count" -eq 1 ]]; then
        slash_command="/ff_vocab_${LANG_CODE}"
        card_type="vocabulary"
    else
        slash_command="/ff_meaningblock_${LANG_CODE}"
        card_type="phrase"
    fi

    info "Card type: $card_type"
    log "Using slash command: $slash_command"

    # Notify user that we're starting (this may take 30-60 seconds)
    # Subtitle indicates whether this is vocabulary (single word) or phrase (multi-word)
    if [[ "$card_type" == "vocabulary" ]]; then
        notify "Vocabulary Card" "Creating card for: $input" "default"
    else
        notify "Phrase Card" "Creating card for: $input" "default"
    fi

    # Invoke Claude Code with the appropriate slash command
    # -p: print mode (non-interactive)
    # --allowedTools: restrict to only necessary tools
    # --dangerously-skip-permissions: required for non-interactive use (script runs in trusted context)
    # Note: prompt must be passed via stdin for slash commands to work properly
    local claude_output
    local exit_code

    claude_output=$(echo "$slash_command $input" | "$CLAUDE_PATH" \
        -p \
        --allow-dangerously-skip-permissions \
        --dangerously-skip-permissions \
        --allowedTools "mcp__anki-mcp__list_decks,mcp__anki-mcp__create_note,mcp__anki-mcp__generate_and_save_audio,mcp__anki-mcp__update_note,mcp__anki-mcp__get_deck_note_types,WebFetch" 2>&1) || exit_code=$?

    # Log full output for debugging
    log "Claude output:"
    log "$claude_output"

    if [[ -z "$exit_code" || "$exit_code" -eq 0 ]]; then
        notify "Success" "$(echo "$card_type" | awk '{print toupper(substr($0,1,1)) substr($0,2)}') card created for: $input" "Glass"
        exit 0
    else
        # Extract meaningful error message from Claude output
        local error_msg
        if echo "$claude_output" | grep -q "limit reached"; then
            error_msg=$(echo "$claude_output" | grep -o ".*limit reached[^·]*" | head -1)
        elif echo "$claude_output" | grep -qi "error"; then
            error_msg=$(echo "$claude_output" | grep -i "error" | head -1 | cut -c1-80)
        else
            # Take last non-empty line as error hint
            error_msg=$(echo "$claude_output" | grep -v '^$' | tail -1 | cut -c1-80)
        fi

        notify "Failed" "${error_msg:-Failed to create $card_type card for: $input}" "Basso"
        exit 4
    fi
}

main "$@"
