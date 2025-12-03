#!/bin/bash
exec > /tmp/flashcard-debug.log 2>&1
echo "=== Debug started at $(date) ==="
echo "PATH: $PATH"
echo "Input: $1"
echo "which terminal-notifier: $(which terminal-notifier 2>&1)"
echo "which claude: $(which claude 2>&1)"
echo "HOME: $HOME"
echo ""
echo "=== Testing notification ==="
/opt/homebrew/bin/terminal-notifier -title "Debug Step 1" -message "Starting..." -sound default
echo "Notification sent, exit code: $?"
echo ""
echo "=== Testing pgrep for Anki ==="
pgrep -x Anki && echo "Anki found via pgrep -x" || echo "Anki NOT found via pgrep -x"
pgrep -f "aqt.run" && echo "Anki found via aqt.run" || echo "Anki NOT found via aqt.run"
echo ""
echo "=== Testing curl to AnkiConnect ==="
curl -s --connect-timeout 3 -X POST "http://localhost:8765" -d '{"action": "version", "version": 6}' 2>&1
echo ""
echo "Curl exit code: $?"
echo ""
echo "=== Testing Claude path ==="
CLAUDE_PATH="${HOME}/.local/bin/claude"
echo "Claude path: $CLAUDE_PATH"
ls -la "$CLAUDE_PATH" 2>&1
echo ""
echo "=== All checks done ==="
/opt/homebrew/bin/terminal-notifier -title "Debug Complete" -message "Check /tmp/flashcard-debug.log" -sound Glass
