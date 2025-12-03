# Quick Start Guide

Get French Anki flashcards generated automatically from any text you select on your Mac. This guide takes you from zero to working in about 30 minutes.

---

## What You'll Get

After setup, you can:
1. Select any French word or phrase anywhere on your Mac
2. Right-click → Services → "Create French Flashcard"
3. Get a rich Anki card with audio pronunciation, definitions, examples, and more

---

## Prerequisites

- **macOS** (tested on Sonoma 14.x)
- **Admin access** to install software
- **Internet connection** for API access
- About **30 minutes** of your time

---

## Step 1: Install Homebrew

Homebrew is a package manager for macOS. If you already have it, skip to Step 2.

Open **Terminal** (press `Cmd + Space`, type "Terminal", press Enter) and paste:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the prompts. When done, **close and reopen Terminal**.

Verify it works:
```bash
brew --version
```

You should see something like `Homebrew 4.x.x`.

---

## Step 2: Install Terminal Notifier

This shows macOS notifications when cards are created.

```bash
brew install terminal-notifier
```

Verify:
```bash
terminal-notifier -title "Test" -message "It works!" -sound default
```

You should see a notification pop up.

---

## Step 3: Install Anki

1. Download Anki from https://apps.ankiweb.net/
2. Open the downloaded `.dmg` file
3. Drag Anki to your Applications folder
4. Open Anki from Applications

---

## Step 4: Install AnkiConnect Addon

AnkiConnect lets external programs create cards in Anki.

1. In Anki, go to **Tools → Add-ons → Get Add-ons...**
2. Enter this code: `2055492159`
3. Click **OK**
4. **Restart Anki** (quit and reopen)

Verify it's working (with Anki open):
```bash
curl -s -X POST "http://localhost:8765" -d '{"action": "version", "version": 6}'
```

You should see: `{"result": 6, "error": null}`

---

## Step 5: Create Anki Decks

In Anki:

1. Click **Create Deck** at the bottom
2. Name it exactly: `French::Vocabulary`
3. Click **OK**
4. Click **Create Deck** again
5. Name it exactly: `French::Phrases`
6. Click **OK**

You should now see both decks in your deck list.

---

## Step 6: Create Anki Note Types

This is the longest step. You need to create two custom note types with specific fields.

### Create ff_vocab Note Type

1. Go to **Tools → Manage Note Types**
2. Click **Add**
3. Select **Add: Basic** and click **OK**
4. Name it exactly: `ff_vocab`
5. Click **OK**
6. With `ff_vocab` selected, click **Fields...**
7. Rename `Front` to `Word` (click Rename)
8. Rename `Back` to `Morpho`
9. Click **Add** and add these fields one by one (in this order):

```
Pronunciation
word_audio
meaning
meaning_translation
Synonyms
Antonyms
Variations
Confusables
Word_Family
Etymology
memory_hook
collocation_1
collocation_1_translation
collocation_1_audio
collocation_2
collocation_2_translation
collocation_2_audio
collocation_3
collocation_3_translation
collocation_3_audio
collocation_4
collocation_4_translation
collocation_4_audio
collocation_5
collocation_5_translation
collocation_5_audio
example_usage_1
example_usage_1_translation
example_usage_1_audio
example_usage_2
example_usage_2_translation
example_usage_2_audio
example_usage_3
example_usage_3_translation
example_usage_3_audio
wr_link
```

10. Click **Save** when done (you should have 39 fields total)

### Create ff_meaningblocks Note Type

1. Still in **Manage Note Types**, click **Add**
2. Select **Add: Basic** and click **OK**
3. Name it exactly: `ff_meaningblocks`
4. Click **OK**
5. With `ff_meaningblocks` selected, click **Fields...**
6. Rename `Front` to `phrase`
7. Rename `Back` to `pronunciation`
8. Click **Add** and add these fields:

```
meaning
usage_notes
example_usage_1
example_usage_1_translation
example_usage_2
example_usage_2_translation
example_usage_3
example_usage_3_translation
phrase_audio
example_usage_1_audio
example_usage_2_audio
example_usage_3_audio
```

9. Click **Save** when done (you should have 14 fields total)
10. Click **Close** to exit Manage Note Types

---

## Step 7: Install Claude Code CLI

Claude Code is Anthropic's command-line AI assistant.

```bash
# Install via npm (requires Node.js)
brew install node
npm install -g @anthropic-ai/claude-code
```

Or use the native installer:
```bash
# Download and run the installer
curl -fsSL https://claude.ai/install.sh | sh
```

Verify installation:
```bash
claude --version
```

Now authenticate with your Anthropic account:
```bash
claude login
```

Follow the prompts to log in via browser.

---

## Step 8: Set Up ElevenLabs Account

ElevenLabs provides the French text-to-speech for audio pronunciations.

1. Go to https://elevenlabs.io/ and create an account
2. Navigate to your **Profile** → **API Keys**
3. Click **Create API Key**
4. Copy the key (starts with `sk_`)

Add the key to your shell configuration:

```bash
# Open your shell config file
nano ~/.zshrc
```

Add this line at the end (replace with your actual key):
```bash
export ELEVENLABS_API_KEY='sk_your_actual_key_here'
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter`).

Load the new config:
```bash
source ~/.zshrc
```

Verify:
```bash
echo $ELEVENLABS_API_KEY
```

You should see your API key printed.

---

## Step 9: Clone the Project

Choose where to put the project. We recommend:

```bash
# Create a projects directory if you don't have one
mkdir -p ~/GitHub/projects
cd ~/GitHub/projects

# Clone the repository
git clone https://github.com/ajanderson/ff_poc_anki.git
cd ff_poc_anki
```

Make the main script executable:
```bash
chmod +x ff_french.sh
```

---

## Step 10: Configure MCP Servers

MCP (Model Context Protocol) servers allow Claude to interact with Anki and ElevenLabs.

### Install anki-mcp

```bash
# Install the Anki MCP server
npm install -g anki-mcp
```

### Configure Claude to Use MCP Servers

Create or edit the MCP configuration:

```bash
mkdir -p ~/.claude/mcp
nano ~/.claude/mcp/anki.json
```

Add this configuration:
```json
{
  "mcpServers": {
    "anki-mcp": {
      "type": "stdio",
      "command": "npx",
      "args": ["anki-mcp"],
      "env": {}
    }
  }
}
```

Save and exit.

For ElevenLabs TTS, you may need to configure the MCP_DOCKER server or use the built-in anki-mcp audio generation. Check your Claude Code MCP settings with:

```bash
claude mcp list
```

---

## Step 11: Update File Paths

The scripts have hardcoded paths that need to match your setup.

### Update ff_french.sh

Open the file:
```bash
nano ~/GitHub/projects/ff_poc_anki/ff_flashcard.sh
```

Find line 22 and update the path if different:
```bash
cd "/Users/YOURUSERNAME/GitHub/projects/ff_poc_anki" || exit 1
```

Replace `YOURUSERNAME` with your actual macOS username.

Save and exit.

### Update ff_french.applescript

Open the file:
```bash
nano ~/GitHub/projects/ff_poc_anki/quickactions/ff_french.applescript
```

Find line 40 and update:
```applescript
set scriptPath to "/Users/YOURUSERNAME/GitHub/projects/ff_poc_anki/ff_flashcard.sh"
```

Replace `YOURUSERNAME` with your actual macOS username.

Save and exit.

---

## Step 12: Create macOS Quick Action

This lets you right-click on selected text to create flashcards.

1. Open **Automator** (press `Cmd + Space`, type "Automator")
2. Click **New Document**
3. Select **Quick Action** and click **Choose**
4. At the top, set:
   - "Workflow receives current" → **text**
   - "in" → **any application**
5. In the left sidebar, search for **Run AppleScript**
6. Drag **Run AppleScript** to the workflow area on the right
7. Delete the placeholder code and paste the entire contents of `ff_french.applescript`:

```applescript
(*
    ff_french.applescript - macOS Quick Action wrapper for French flashcard creation
*)

on run {input, parameters}
    try
        -- Validate input
        if input is missing value then
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki French Card' -subtitle 'Error' -message 'No input provided' -sound Basso"
            return "Error: No input provided"
        end if

        -- Convert input to string and trim whitespace
        set targetText to (input as string)
        set targetText to do shell script "echo " & quoted form of targetText & " | xargs"

        if targetText is "" then
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki French Card' -subtitle 'Error' -message 'Empty input' -sound Basso"
            return "Error: Empty input"
        end if

        -- Path to the bash script (UPDATE THIS PATH!)
        set scriptPath to "/Users/YOURUSERNAME/GitHub/projects/ff_poc_anki/ff_flashcard.sh"

        -- Build the shell command
        set shellCommand to quoted form of scriptPath & " " & quoted form of targetText

        -- Execute the bash script
        do shell script shellCommand

        return targetText

    on error errMsg number errNum
        try
            do shell script "/opt/homebrew/bin/terminal-notifier -title 'Anki French Card' -subtitle 'Error' -message " & quoted form of errMsg & " -sound Basso"
        end try
        return "Error: " & errMsg
    end try
end run
```

8. **IMPORTANT:** Change `YOURUSERNAME` on line 23 to your actual macOS username
9. Press `Cmd + S` to save
10. Name it: `Create French Flashcard`
11. Close Automator

---

## Step 13: Test Everything

### Test 1: Command Line

Make sure Anki is running, then:

```bash
cd ~/GitHub/projects/ff_poc_anki
./ff_french.sh "bonjour"
```

You should see:
- A notification saying "Creating card for: bonjour"
- Lots of output as Claude works
- A success notification
- A new card in Anki's `French::Vocabulary` deck

### Test 2: Quick Action

1. Open any app (Safari, Notes, TextEdit, etc.)
2. Type or find a French word, like: `merci`
3. Select the word
4. Right-click → **Services** → **Create French Flashcard**
5. Wait for the success notification
6. Check Anki for the new card

### Test 3: Phrase Card

```bash
./ff_french.sh "c'est-à-dire"
```

This should create a card in the `French::Phrases` deck.

---

## Troubleshooting

### "Anki is not running"

Start Anki before creating flashcards.

### "AnkiConnect not responding"

1. Make sure AnkiConnect addon is installed (Step 4)
2. Restart Anki
3. Wait 5 seconds after Anki opens before trying

### "Command not found: claude"

```bash
# Add to your PATH
export PATH="${HOME}/.local/bin:${PATH}"
# Then add this line to ~/.zshrc to make it permanent
```

### "Quick Action not appearing"

1. Go to **System Preferences → Keyboard → Shortcuts → Services**
2. Find "Create French Flashcard" and make sure it's checked
3. Try restarting the app where you're selecting text

### Check the Debug Log

```bash
tail -50 /tmp/french-flashcard.log
```

This shows what happened during the last flashcard creation attempt.

---

## Quick Reference

| Command | What it does |
|---------|--------------|
| `./ff_french.sh "word"` | Create vocabulary card for single word |
| `./ff_french.sh "some phrase"` | Create phrase card for multi-word expression |
| `tail -f /tmp/french-flashcard.log` | Watch the debug log in real-time |
| `claude mcp list` | Show configured MCP servers |
| `curl -s -X POST "http://localhost:8765" -d '{"action": "deckNames", "version": 6}'` | Test AnkiConnect |

---

## File Locations Summary

| What | Where |
|------|-------|
| Project files | `~/GitHub/projects/ff_poc_anki/` |
| Claude CLI | `~/.local/bin/claude` |
| Claude config | `~/.claude/` |
| Debug log | `/tmp/french-flashcard.log` |
| ElevenLabs API key | `~/.zshrc` (as environment variable) |
| Quick Action | `~/Library/Services/Create French Flashcard.workflow` |

---

## Next Steps

- Try creating cards for words you encounter while reading
- Customize the card templates in `templates/` folder
- Review cards daily in Anki
- Check `TROUBLESHOOTING.md` if you run into issues

Happy learning! 🇫🇷
