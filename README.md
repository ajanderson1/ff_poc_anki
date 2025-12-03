# Anki Flashcard Generator

A multi-language Anki flashcard generator powered by Claude Code and MCP (Model Context Protocol). Select text anywhere on macOS, trigger a Quick Action, and get rich flashcards with audio pronunciations automatically created in Anki.

## Features

- **One-click flashcard creation**: Select text anywhere on macOS, right-click, and create a flashcard
- **Multi-language support**: Currently supports French and Swedish, extensible to any language
- **Automatic card type detection**: Single words create vocabulary cards; multi-word phrases create phrase cards
- **Audio pronunciations**: Native TTS via ElevenLabs with language-specific voices
- **Rich vocabulary cards**: Morphology, definitions (native + English), synonyms, antonyms, collocations, example sentences, etymology, and memory hooks
- **Phrase cards**: Contextual usage, translations, and example sentences with audio

## How It Works

```
macOS Quick Action
    └── ff_flashcard.sh --lang=XX
            ├── Pre-flight checks (Anki running? AnkiConnect responding?)
            ├── Loads config/languages/XX.conf (voice ID, deck prefix, etc.)
            └── Claude Code CLI
                    ├── Slash command: /ff_vocab_XX or /ff_meaningblock_XX
                    └── anki-mcp server
                            ├── Creates card via AnkiConnect API
                            └── Generates audio via ElevenLabs API
```

### Implementation Details

The project uses **Claude Code** as the AI backbone, invoked non-interactively via the CLI. Claude processes the input word/phrase using language-specific slash commands (`.claude/commands/ff_vocab_XX.md`) that define the card structure, field mappings, and generation logic.

**APIs Used:**
- **AnkiConnect** (port 8765): REST API addon for Anki that allows external programs to create, update, and query flashcards
- **ElevenLabs**: Text-to-speech API for generating native pronunciation audio files

All API interactions happen through the **anki-mcp** server, which provides Claude with MCP tools for both Anki operations and audio generation.

## Dependencies

- **macOS** (tested on Sonoma)
- **[Anki](https://apps.ankiweb.net/)** with [AnkiConnect](https://ankiweb.net/shared/info/2055492159) addon (code: `2055492159`)
- **[Claude Code CLI](https://github.com/anthropics/claude-code)**
- **[anki-mcp-elevenlabs](https://github.com/spencerf2/anki-mcp-elevenlabs.git)** by [Spencer Franklin](https://github.com/spencerf2/anki-mcp-elevenlabs/commits?author=spencerf2)  Anki MCP Server with ElevenLabs Support
- **[terminal-notifier](https://github.com/julienXX/terminal-notifier)**: `brew install terminal-notifier`
- **ElevenLabs API key** set as `ELEVENLABS_API_KEY` environment variable

## Integration with Anki

### Required Addon

Install the **AnkiConnect** addon:
1. In Anki: Tools → Add-ons → Get Add-ons...
2. Enter code: `2055492159`
3. Restart Anki

Verify it's working:
```bash
curl -s -X POST "http://localhost:8765" -d '{"action": "version", "version": 6}'
# Should return: {"result": 6, "error": null}
```

### Required Decks

Create these decks in Anki (use `::` for hierarchy):
- `{Language}::Vocabulary` (e.g., `French::Vocabulary`, `Swedish::Vocabulary`)
- `{Language}::Phrases` (e.g., `French::Phrases`, `Swedish::Phrases`)

### Required Note Types

Two note types must exist with specific field structures:

**ff_vocab** (39 fields) - For vocabulary cards:
- Word, Morpho, Pronunciation, word_audio
- meaning, meaning_translation
- Synonyms, Antonyms, Variations, Confusables, Word_Family
- Etymology, memory_hook
- 5 collocations (each with text, translation, audio)
- 3 example usages (each with text, translation, audio)
- wr_link (reference link)

**ff_meaningblocks** (14 fields) - For phrase cards:
- phrase, pronunciation, meaning, usage_notes
- 3 example usages (each with text, translation)
- phrase_audio, example_usage_1_audio, example_usage_2_audio, example_usage_3_audio

See [`docs/QUICKSTART.md`](docs/QUICKSTART.md) for step-by-step field creation instructions.

## Usage

### Via macOS Quick Action

1. Select text in any application
2. Right-click → Services → "{Language} Flashcard"
3. Wait for the success notification
4. Check Anki for the new card

### Via Command Line

```bash
# French vocabulary card
./ff_flashcard.sh --lang=fr "bonjour"

# Swedish vocabulary card
./ff_flashcard.sh --lang=sv "hej"

# French phrase card (multi-word)
./ff_flashcard.sh --lang=fr "c'est-à-dire"

# Swedish phrase card
./ff_flashcard.sh --lang=sv "i alla fall"
```

## Adding a New Language

1. Create `config/languages/{lang}.conf`:
   ```bash
   LANG_CODE="xx"
   LANG_NAME="Language Name"
   LANG_TTS_CODE="xx-XX"
   LANG_VOICE_ID="elevenlabs-voice-id"
   LANG_DECK_PREFIX="LanguageName"
   LANG_REFERENCE="DictionaryName"
   LANG_REFERENCE_URL="https://dictionary.example.com/"
   ```

2. Create `.claude/commands/ff_vocab_{lang}.md` (adapt from existing)
3. Create `.claude/commands/ff_meaningblock_{lang}.md`
4. Create `quickactions/ff_{lang}.applescript`
5. Set up macOS Quick Action in Automator

The main script auto-routes based on `--lang` parameter - no code changes needed.

## Project Structure

```
ff_poc_anki/
├── ff_flashcard.sh              # Unified entry point
├── config/
│   └── languages/               # Language-specific configs
│       ├── fr.conf
│       └── sv.conf
├── quickactions/                # macOS Automator wrappers
├── .claude/
│   ├── commands/                # Slash commands per language
│   │   ├── ff_vocab_fr.md
│   │   ├── ff_vocab_sv.md
│   │   ├── ff_meaningblock_fr.md
│   │   └── ff_meaningblock_sv.md
│   └── guides/                  # Shared documentation
│       ├── tagging-guide.md
│       ├── vocab-field-guide.md
│       └── audio-generation-guide.md
├── anki_card_templates/         # Anki card HTML/CSS templates
├── template_anki_decks/         # Pre-configured Anki deck exports
├── docs/
│   ├── QUICKSTART.md            # Full setup guide
│   └── TROUBLESHOOTING.md       # Common issues
└── CLAUDE.md                    # Claude Code project guidance
```

## Troubleshooting

Debug logs are written to `/tmp/flashcard.log`:
```bash
tail -f /tmp/flashcard.log
```

Common issues:
- **"Anki is not running"**: Start Anki before creating flashcards
- **"AnkiConnect not responding"**: Ensure addon is installed and restart Anki
- **No Quick Action appearing**: Check System Settings → Keyboard → Keyboard Shortcuts → Services

See [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) for detailed solutions.

## License

MIT
