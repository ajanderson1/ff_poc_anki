#!/bin/bash
#
# ff_batch.sh - Batch create Anki flashcards from a file
#
# Reads a file containing one word or phrase per line and creates
# a flashcard for each using ff_flashcard.sh
#
# Usage: ./ff_batch.sh --lang=<code> <input_file>
#
# Example:
#   ./ff_batch.sh --lang=fr words.txt
#   ./ff_batch.sh --lang=sv swedish_phrases.txt
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLASHCARD_SCRIPT="${SCRIPT_DIR}/ff_flashcard.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat <<EOF
Usage: $0 --lang=<code> <input_file>

Batch create Anki flashcards from a file containing words or phrases.

Arguments:
  --lang=<code>   Language code (required)
                  Supported: fr (French), sv (Swedish)
  <input_file>    File with one word or phrase per line

Options:
  -h, --help      Show this help message
  -d, --delay N   Delay N seconds between cards (default: 2)
  -n, --dry-run   Show what would be processed without creating cards

Examples:
  $0 --lang=fr french_words.txt
  $0 --lang=sv --delay=5 swedish_phrases.txt
  $0 --lang=fr --dry-run vocabulary.txt

Input file format:
  One word or phrase per line. Empty lines and lines starting with # are skipped.

  Example file contents:
    bonjour
    au revoir
    # This is a comment
    c'est-à-dire

EOF
    exit 0
}

error() {
    echo -e "${RED}ERROR:${NC} $1" >&2
    exit 1
}

info() {
    echo -e "${BLUE}INFO:${NC} $1"
}

success() {
    echo -e "${GREEN}OK:${NC} $1"
}

warn() {
    echo -e "${YELLOW}WARN:${NC} $1"
}

# Defaults
DELAY=2
DRY_RUN=false
LANG_ARG=""
INPUT_FILE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --lang=*)
            LANG_ARG="$1"
            shift
            ;;
        -d|--delay)
            DELAY="$2"
            shift 2
            ;;
        --delay=*)
            DELAY="${1#*=}"
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            error "Unknown option: $1\nUse --help for usage information."
            ;;
        *)
            if [[ -z "$INPUT_FILE" ]]; then
                INPUT_FILE="$1"
            else
                error "Unexpected argument: $1\nUse --help for usage information."
            fi
            shift
            ;;
    esac
done

# Validate arguments
if [[ -z "$LANG_ARG" ]]; then
    error "Language argument required.\nUsage: $0 --lang=<code> <input_file>\nUse --help for more information."
fi

if [[ -z "$INPUT_FILE" ]]; then
    error "Input file required.\nUsage: $0 --lang=<code> <input_file>\nUse --help for more information."
fi

if [[ ! -f "$INPUT_FILE" ]]; then
    error "Input file not found: $INPUT_FILE"
fi

if [[ ! -x "$FLASHCARD_SCRIPT" ]]; then
    error "Flashcard script not found or not executable: $FLASHCARD_SCRIPT"
fi

# Count valid lines (non-empty, non-comment)
total=$(grep -cvE '^\s*$|^\s*#' "$INPUT_FILE" 2>/dev/null || echo "0")

if [[ "$total" -eq 0 ]]; then
    error "No valid entries found in $INPUT_FILE"
fi

info "Processing $total entries from: $INPUT_FILE"
info "Language: ${LANG_ARG#--lang=}"
info "Delay between cards: ${DELAY}s"

if [[ "$DRY_RUN" == true ]]; then
    warn "DRY RUN - no cards will be created"
    echo ""
fi

# Process each line
count=0
success_count=0
fail_count=0

while IFS= read -r line || [[ -n "$line" ]]; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

    # Trim whitespace
    line=$(echo "$line" | xargs)
    [[ -z "$line" ]] && continue

    ((count++))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "[$count/$total] Processing: $line"

    if [[ "$DRY_RUN" == true ]]; then
        echo "  Would run: $FLASHCARD_SCRIPT $LANG_ARG \"$line\""
        ((success_count++))
    else
        # Use </dev/null to prevent Claude from waiting on stdin
        if "$FLASHCARD_SCRIPT" "$LANG_ARG" "$line" </dev/null; then
            success "Card created for: $line"
            ((success_count++))
        else
            warn "Failed to create card for: $line"
            ((fail_count++))
        fi

        # Delay between cards (except for last one)
        if [[ $count -lt $total ]]; then
            info "Waiting ${DELAY}s before next card..."
            sleep "$DELAY"
        fi
    fi

done < "$INPUT_FILE"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}SUMMARY${NC}"
echo "  Total processed: $count"
echo -e "  ${GREEN}Successful:${NC} $success_count"
if [[ $fail_count -gt 0 ]]; then
    echo -e "  ${RED}Failed:${NC} $fail_count"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
