(*
    ff_swedish.applescript - macOS Quick Action wrapper for Swedish flashcard creation

    This script is designed to be used as a macOS Quick Action (Service).
    It receives selected text and passes it to ff_flashcard.sh with --lang=sv,
    which automatically routes to vocabulary (single word) or phrase (multi-word) workflows.

    Setup Instructions:
    1. Open Automator.app
    2. Create new "Quick Action"
    3. Set "Workflow receives current" to "text" in "any application"
    4. Add "Run AppleScript" action
    5. Paste this entire script
    6. Save as "Swedish Flashcard"

    The service will then appear in:
    - Right-click context menu on selected text
    - Application menu > Services
    - System Preferences > Keyboard > Shortcuts > Services (to add keyboard shortcut)
*)

on run {input, parameters}
    try
        -- Validate input
        if input is missing value then
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki Swedish Card' -subtitle 'Error' -message 'No input provided' -sound Basso"
            return "Error: No input provided"
        end if

        -- Convert input to string and trim whitespace
        set targetText to (input as string)
        set targetText to do shell script "echo " & quoted form of targetText & " | xargs"

        if targetText is "" then
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki Swedish Card' -subtitle 'Error' -message 'Empty input' -sound Basso"
            return "Error: Empty input"
        end if

        -- Path to the unified bash script (UPDATE THIS PATH to your installation location)
        set scriptPath to "/path/to/ff_poc_anki/ff_flashcard.sh"

        -- Build the shell command with --lang=sv and proper quoting
        set shellCommand to quoted form of scriptPath & " --lang=sv " & quoted form of targetText

        -- Execute the bash script
        -- Note: This runs synchronously. The bash script handles all notifications.
        do shell script shellCommand

        return targetText

    on error errMsg number errNum
        -- Show error notification
        try
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki Swedish Card' -subtitle 'Error' -message " & quoted form of errMsg & " -sound Basso"
        end try
        return "Error: " & errMsg
    end try
end run
