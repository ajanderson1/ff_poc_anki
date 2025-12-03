# Troubleshooting Guide

This document provides comprehensive documentation of all dependencies, configurations, and potential failure points for the French Anki Flashcard Generator project. Use this guide to diagnose and fix issues when components change.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Hardcoded Paths & Locations](#hardcoded-paths--locations)
3. [MCP Server Dependencies](#mcp-server-dependencies)
4. [API Keys & Credentials](#api-keys--credentials)
5. [Anki Configuration](#anki-configuration)
6. [Claude Code Configuration](#claude-code-configuration)
7. [External Service Dependencies](#external-service-dependencies)
8. [Common Failure Scenarios](#common-failure-scenarios)
9. [Diagnostic Commands](#diagnostic-commands)
10. [Migration Checklist](#migration-checklist)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        macOS Quick Action (Services)                        │
│                    "Create French Flashcard" right-click                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                         ff_french.applescript                               │
│              Automator wrapper - validates input, calls bash                │
│                                                                             │
│  HARDCODED PATH: /path/to/ff_poc_anki/ff_flashcard.sh                       │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            ff_french.sh                                     │
│         Unified entry point - pre-flight checks, word count routing         │
│                                                                             │
│  DEPENDENCIES:                                                              │
│  • curl (AnkiConnect check)                                                 │
│  • pgrep (Anki process check)                                               │
│  • terminal-notifier (notifications)                                        │
│  • claude (Claude Code CLI)                                                 │
│                                                                             │
│  ROUTING:                                                                   │
│  • 1 word  → /ff_vocab_fr slash command                                     │
│  • 2+ words → /ff_meaningblock_fr slash command                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────────┐
│     /ff_vocab_fr command        │   │     /ff_meaningblock_fr command     │
│  .claude/commands/ff_vocab_fr.md │   │ .claude/commands/ff_meaningblock_fr.md │
│                                 │   │                                     │
│  39 fields, WordReference-based │   │  14 fields, phrase/expression focus │
│  Deck: French::Vocabulary       │   │  Deck: French::Phrases              │
│  Model: ff_vocab                │   │  Model: ff_meaningblocks            │
└─────────────────────────────────┘   └─────────────────────────────────────┘
                    │                                   │
                    └─────────────────┬─────────────────┘
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                           MCP Server Layer                                  │
├─────────────────────────────────┬───────────────────────────────────────────┤
│         anki-mcp                │           ElevenLabs (MCP_DOCKER)         │
│    (AnkiConnect bridge)         │         (Text-to-Speech API)              │
│                                 │                                           │
│  Tools:                         │  Tool:                                    │
│  • list_decks                   │  • generate_and_save_audio                │
│  • create_note                  │                                           │
│  • update_note                  │  Voice ID: JdwJ7jL68CWmQZuo7KgG           │
│  • get_deck_note_types          │  Language: fr-FR                          │
│  • generate_and_save_audio      │                                           │
└─────────────────────────────────┴───────────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
┌─────────────────────────────────┐   ┌─────────────────────────────────────┐
│     AnkiConnect Addon           │   │         WordReference.com           │
│     http://localhost:8765       │   │   (via WebFetch for definitions)    │
│                                 │   │                                     │
│  Requires Anki to be running    │   │  URL pattern:                       │
│  with AnkiConnect addon active  │   │  wordreference.com/fren/{word}      │
└─────────────────────────────────┘   └─────────────────────────────────────┘
```

---

## Hardcoded Paths & Locations

### Critical Paths to Update If Project Moves

| File | Line | Path | Purpose |
|------|------|------|---------|
| `ff_flashcard.sh` | N/A | Uses `SCRIPT_DIR` dynamically | Project directory (cd target) |
| `ff_french.sh` | 36 | `${HOME}/.local/bin/claude` | Claude CLI binary location |
| `ff_french.sh` | 37 | `/opt/homebrew/bin/terminal-notifier` | macOS notification tool |
| `ff_french.sh` | 34 | `http://localhost:8765` | AnkiConnect API endpoint |
| `ff_french.sh` | 25 | `/tmp/french-flashcard.log` | Debug log file |
| `ff_{lang}.applescript` | 40 | `/path/to/ff_poc_anki/ff_flashcard.sh` | Path to main script (update after cloning) |
| `ff_french.applescript` | 26, 35, 54 | `/opt/homebrew/bin/terminal-notifier` | Notification tool (hardcoded 3x) |

### PATH Dependencies

The scripts prepend these to PATH (line 19 of `ff_french.sh`):
```bash
export PATH="/opt/homebrew/bin:${HOME}/.local/bin:${PATH}"
```

Required binaries in these locations:
- `/opt/homebrew/bin/terminal-notifier` - Homebrew-installed notification tool
- `${HOME}/.local/bin/claude` - Claude Code CLI

### If You Move the Project

1. Update `ff_french.applescript` line 40 with new path to `ff_french.sh`
2. Update `ff_french.sh` line 22 with new project directory
3. Re-export the Automator Quick Action workflow

---

## MCP Server Dependencies

### 1. anki-mcp Server

**Purpose:** Bridge between Claude Code and AnkiConnect API

**Required Tools (used in --allowedTools):**
```
mcp__anki-mcp__list_decks
mcp__anki-mcp__create_note
mcp__anki-mcp__generate_and_save_audio
mcp__anki-mcp__update_note
mcp__anki-mcp__get_deck_note_types
```

**Configuration Location:** Configured globally in Claude Code MCP settings (not project-local)

**Verification:**
```bash
# Test if AnkiConnect is responding
curl -s -X POST "http://localhost:8765" -d '{"action": "version", "version": 6}'
# Expected: {"result": 6, "error": null}
```

### 2. ElevenLabs MCP Server (via MCP_DOCKER)

**Purpose:** Text-to-speech audio generation for French pronunciations

**Required Tool:**
```
mcp__anki-mcp__generate_and_save_audio
```

**Voice Configuration:**
- Provider: `elevenlabs`
- Voice ID: `JdwJ7jL68CWmQZuo7KgG`
- Language: `fr-FR`

**If Voice Stops Working:**
1. Check ElevenLabs account status
2. Verify voice ID is still valid in ElevenLabs dashboard
3. Check if voice has been deleted or renamed
4. Search for replacement voice: `mcp__MCP_DOCKER__search_voices`

### MCP Server Health Check

The slash commands begin with MCP availability check:
```
1. Check Anki MCP availability - Use `mcp__anki-mcp__list_decks` to verify the MCP is working
```

If MCP fails, commands fall back to text output mode.

---

## API Keys & Credentials

### ElevenLabs API Key

**Location:** `~/.zshrc`
```bash
export ELEVENLABS_API_KEY='your-api-key-here'
```

**If Key Changes:**
1. Update the value in `~/.zshrc`
2. Source the file: `source ~/.zshrc`
3. Restart any running Claude Code sessions

**If Key Expires/Invalid:**
1. Log into ElevenLabs dashboard
2. Generate new API key
3. Update `~/.zshrc`
4. Restart terminal sessions

### Claude Code Authentication

**Location:** `~/.claude/.credentials.json`

This is managed automatically by Claude Code. If authentication fails:
```bash
claude login
```

---

## Anki Configuration

### Required Anki Setup

1. **Anki Application** must be running
2. **AnkiConnect addon** must be installed (addon code: 2055492159)
3. **AnkiConnect settings:** Default port 8765

### Anki Decks (must exist)

| Deck Name | Card Type |
|-----------|-----------|
| `French::Vocabulary` | Vocabulary cards (single words) |
| `French::Phrases` | Phrase/meaningblock cards |

### Anki Note Types (models)

#### ff_vocab (39 fields)

For vocabulary cards:

| Field Name | Purpose |
|------------|---------|
| Word | French headword (lowercase, masculine form for adj/adv) |
| Morpho | Part of speech, gender, variations (WR abbreviations) |
| Pronunciation | Friendly respelling + IPA |
| word_audio | Audio file in `[sound:uuid.mp3]` format |
| meaning | French definitions (up to 6) |
| meaning_translation | English translations |
| Synonyms | 3-8 French synonyms |
| Antonyms | Up to 3 antonyms |
| Variations | Singular/plural, masc/fem forms |
| Confusables | Similar/confused words with hints |
| Word_Family | Morphologically related words |
| Etymology | Word origin |
| memory_hook | English speaker mnemonic |
| collocation_1 through collocation_5 | Short phrases (+ _translation, _audio) |
| example_usage_1 through example_usage_3 | Full sentences (+ _translation, _audio) |
| wr_link | WordReference URL |

#### ff_meaningblocks (14 fields)

For phrase cards:

| Field Name | Purpose |
|------------|---------|
| phrase | French phrase (lowercase) |
| pronunciation | Friendly respelling |
| meaning | English translation(s) |
| usage_notes | Usage guidance |
| example_usage_1 through example_usage_3 | Full sentences + translations |
| phrase_audio | Audio file for phrase |
| example_usage_1_audio through example_usage_3_audio | Audio for examples |

### If Note Types Are Missing

Create them in Anki via Tools → Manage Note Types, or the cards will fail to create.

---

## Claude Code Configuration

### Settings Locations

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | Global Claude Code settings (hooks, plugins) |
| `~/.claude/settings.local.json` | Local permissions settings |
| `~/.claude.json` | User preferences, history |
| `/project/.claude/commands/*.md` | Project slash commands |

### Current Global Settings

```json
{
  "includeCoAuthoredBy": false,
  "hooks": { ... },
  "enabledPlugins": {
    "document-skills@anthropic-agent-skills": true,
    "example-skills@anthropic-agent-skills": true
  },
  "alwaysThinkingEnabled": true
}
```

### Allowed Tools for Flashcard Creation

The scripts restrict Claude to specific tools via `--allowedTools`:
```bash
--allowedTools "mcp__anki-mcp__list_decks,mcp__anki-mcp__create_note,mcp__anki-mcp__generate_and_save_audio,mcp__anki-mcp__update_note,mcp__anki-mcp__get_deck_note_types,WebFetch"
```

### If Slash Commands Don't Work

1. Verify Claude is running from project directory (line 22 of `ff_french.sh`)
2. Check that `.claude/commands/ff_vocab_fr.md` exists
3. Check that `.claude/commands/ff_meaningblock_fr.md` exists
4. Verify file permissions allow reading

---

## External Service Dependencies

### 1. WordReference.com

**Used For:** Vocabulary definitions, morphology, IPA pronunciation

**URL Pattern:** `https://www.wordreference.com/fren/{word}`

**If WordReference Changes:**
- Update URL patterns in slash command if domain changes
- Check for rate limiting or blocking
- May need to use alternative dictionary source

### 2. ElevenLabs API

**Used For:** French TTS audio generation

**Endpoint:** Accessed via MCP_DOCKER MCP server

**Voice ID:** `JdwJ7jL68CWmQZuo7KgG`

**Rate Limits:** Check ElevenLabs subscription tier

**If ElevenLabs API Changes:**
1. Check MCP_DOCKER server for updates
2. Verify API key is still valid
3. Check if voice ID format has changed
4. Monitor for deprecated endpoints

### 3. AnkiConnect API

**Local Endpoint:** `http://localhost:8765`

**Version:** Protocol version 6

**If AnkiConnect Changes:**
- Check addon updates in Anki
- Verify API action names haven't changed
- Check port hasn't changed (default: 8765)

---

## Common Failure Scenarios

### Scenario 1: "Anki is not running"

**Exit Code:** 2

**Causes:**
- Anki application not started
- Anki running under different process name

**Solutions:**
1. Start Anki application
2. Check if Anki is running: `pgrep -x Anki` or `pgrep -f "aqt.run"`

---

### Scenario 2: "AnkiConnect not responding"

**Exit Code:** 3

**Causes:**
- AnkiConnect addon not installed
- AnkiConnect addon disabled
- Port 8765 blocked or in use
- Anki just started (addon not yet loaded)

**Solutions:**
1. Install AnkiConnect: Tools → Add-ons → Get Add-ons → Code: 2055492159
2. Enable addon and restart Anki
3. Check port: `lsof -i :8765`
4. Wait a few seconds after Anki starts

---

### Scenario 3: "Claude invocation failed"

**Exit Code:** 4

**Causes:**
- Claude CLI not installed or not in PATH
- Claude not authenticated
- MCP servers not available
- Network issues
- Rate limiting

**Solutions:**
1. Check Claude installation: `which claude`
2. Re-authenticate: `claude login`
3. Check MCP server status
4. Check debug log: `tail -f /tmp/french-flashcard.log`

---

### Scenario 4: No Audio Generated

**Causes:**
- ElevenLabs API key invalid/expired
- Voice ID no longer exists
- MCP_DOCKER server not running
- Rate limit exceeded

**Solutions:**
1. Verify API key in `~/.zshrc`
2. Check voice exists in ElevenLabs dashboard
3. Check MCP server status
4. Check ElevenLabs subscription/usage

---

### Scenario 5: Card Created But Missing Fields

**Causes:**
- WordReference returned no data for word
- Note type fields don't match expected names
- MCP tool failed silently

**Solutions:**
1. Manually check WordReference for the word
2. Verify Anki note type has correct field names
3. Check debug log for errors

---

### Scenario 6: Quick Action Not Appearing

**Causes:**
- Automator workflow not saved correctly
- Services not enabled for application
- Path in AppleScript is wrong

**Solutions:**
1. Re-create Quick Action in Automator
2. System Preferences → Keyboard → Shortcuts → Services
3. Verify path in `ff_french.applescript` line 40

---

## Diagnostic Commands

### Check All Dependencies

```bash
# Check Anki running
pgrep -x Anki && echo "Anki is running" || echo "Anki NOT running"

# Check AnkiConnect
curl -s -X POST "http://localhost:8765" -d '{"action": "version", "version": 6}'

# Check Claude
which claude && claude --version

# Check terminal-notifier
which terminal-notifier && terminal-notifier -version

# Check project directory exists (update path to your installation)
ls -la /path/to/ff_poc_anki/

# Check slash commands exist
ls -la /path/to/ff_poc_anki/.claude/commands/

# Check debug log
tail -50 /tmp/french-flashcard.log
```

### Test Script Manually

```bash
cd /path/to/ff_poc_anki
./ff_flashcard.sh --lang=fr "bonjour"
```

### Test Individual Components

```bash
# Test notification system
/opt/homebrew/bin/terminal-notifier -title "Test" -message "Working" -sound default

# Test AnkiConnect decks
curl -s -X POST "http://localhost:8765" -d '{"action": "deckNames", "version": 6}'

# Test AnkiConnect note types
curl -s -X POST "http://localhost:8765" -d '{"action": "modelNames", "version": 6}'
```

---

## Migration Checklist

Use this checklist when moving the project or setting up on a new machine.

### Pre-Migration

- [ ] Note current ElevenLabs API key
- [ ] Export Anki deck with note types
- [ ] Document any custom hooks/settings
- [ ] Backup `~/.claude/` directory

### Installation Steps

1. **Install Prerequisites**
   - [ ] Install Anki: https://apps.ankiweb.net/
   - [ ] Install AnkiConnect addon (code: 2055492159)
   - [ ] Install Claude Code: https://github.com/anthropics/claude-code
   - [ ] Install terminal-notifier: `brew install terminal-notifier`

2. **Configure API Keys**
   - [ ] Add ElevenLabs API key to `~/.zshrc`:
     ```bash
     export ELEVENLABS_API_KEY='your-key-here'
     ```
   - [ ] Authenticate Claude: `claude login`

3. **Configure MCP Servers**
   - [ ] Set up anki-mcp MCP server
   - [ ] Set up ElevenLabs MCP server (MCP_DOCKER)
   - [ ] Verify MCP tools are available

4. **Set Up Project**
   - [ ] Clone/copy project to desired location
   - [ ] Update paths in `ff_french.sh` (line 22)
   - [ ] Update paths in `ff_french.applescript` (line 40)
   - [ ] Make script executable: `chmod +x ff_french.sh`

5. **Set Up Anki**
   - [ ] Create deck: `French::Vocabulary`
   - [ ] Create deck: `French::Phrases`
   - [ ] Create note type: `ff_vocab` with 39 fields
   - [ ] Create note type: `ff_meaningblocks` with 14 fields

6. **Set Up macOS Quick Action**
   - [ ] Open Automator
   - [ ] Create new Quick Action
   - [ ] Set to receive "text" in "any application"
   - [ ] Add "Run AppleScript" action
   - [ ] Paste contents of `ff_french.applescript`
   - [ ] Save as "Create French Flashcard"

7. **Verification**
   - [ ] Start Anki
   - [ ] Run test: `./ff_french.sh "test"`
   - [ ] Check debug log: `/tmp/french-flashcard.log`
   - [ ] Test Quick Action on selected text

### Post-Migration Verification

```bash
# Full system test
cd /your/new/project/path
./ff_french.sh "bonjour"

# Check the card was created in Anki
# Verify audio files were generated
```

---

## Version History

| Date | Changes |
|------|---------|
| 2025-12-01 | Initial troubleshooting guide created |

---

## Contact & Support

For Claude Code issues: https://github.com/anthropics/claude-code/issues

For AnkiConnect issues: https://github.com/FooSoft/anki-connect

For ElevenLabs API: https://elevenlabs.io/docs
