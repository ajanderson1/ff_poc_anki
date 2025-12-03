# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This project creates vocabulary Anki flashcards via Claude Code with MCP (Model Context Protocol) integration. The workflow enables users to select text in any supported language anywhere on macOS, trigger a Quick Action, and automatically generate a rich Anki flashcard with audio pronunciations.

**Supported Languages:**
- French (fr)
- Swedish (sv)

## Architecture

```
macOS Quick Action (Services menu)
    ├── quickactions/ff_french.applescript → ff_flashcard.sh --lang=fr
    └── quickactions/ff_swedish.applescript → ff_flashcard.sh --lang=sv
            └── ff_flashcard.sh (unified entry point)
                    ├── Sources config/languages/{lang}.conf
                    ├── Pre-flight checks (Anki, AnkiConnect)
                    ├── Word count routing
                    │   ├── Single word → /ff_vocab_{lang} command
                    │   └── Multi-word  → /ff_meaningblock_{lang} command
                    └── anki-mcp (AnkiConnect) + ElevenLabs TTS
```

### Key Components

- **ff_flashcard.sh**: Unified entry point. Accepts `--lang=XX` parameter, loads language config, validates Anki/AnkiConnect, routes to appropriate slash command
- **config/languages/*.conf**: Language-specific configuration (voice ID, deck prefix, reference source)
- **quickactions/ff_{lang}.applescript**: macOS Automator Quick Action wrappers per language
- **.claude/commands/ff_vocab_{lang}.md**: Language-specific vocabulary slash commands
- **.claude/commands/ff_meaningblock_{lang}.md**: Language-specific phrase/expression slash commands
- **.claude/guides/tagging-guide.md**: Comprehensive tagging taxonomy (shared across languages)
- **.claude/guides/vocab-field-guide.md**: Field structure documentation for vocabulary cards
- **.claude/guides/audio-generation-guide.md**: TTS generation instructions
- **templates/vocab_card/**: Anki card HTML/CSS templates for vocabulary cards
- **templates/meaningblock_card/**: Anki card HTML/CSS templates for phrase cards
- **deprecated/**: Old single-language scripts

## Commands

### Create a flashcard manually
```bash
# French vocabulary card
./ff_flashcard.sh --lang=fr "bonjour"

# Swedish vocabulary card
./ff_flashcard.sh --lang=sv "hej"

# French phrase card (multi-word)
./ff_flashcard.sh --lang=fr "c'est-à-dire"

# Swedish phrase card (multi-word)
./ff_flashcard.sh --lang=sv "för övrigt"
```

### Via macOS Quick Action
- Select French text → Right-click → Services → "French Flashcard"
- Select Swedish text → Right-click → Services → "Swedish Flashcard"

The script automatically determines the card type based on word count:
- **1 word** → Vocabulary card (full morphology, collocations)
- **2+ words** → Phrase/meaningblock card (contextual usage focus)

## Language Configuration

Language-specific settings are in `config/languages/{lang}.conf`:

| Setting | French | Swedish |
|---------|--------|---------|
| Voice ID | `JdwJ7jL68CWmQZuo7KgG` | `4Ct5uMEndw4cJ7q0Jx0l` (Elin) |
| TTS Code | `fr-FR` | `sv-SE` |
| Deck Prefix | `French` | `Swedish` |
| Reference | WordReference | WordReference |

## MCP Dependencies

This project requires two MCP servers:
1. **anki-mcp**: Connects to AnkiConnect addon for card operations
2. **ElevenLabs**: TTS for audio pronunciations (voice varies by language)

The bash script pre-checks AnkiConnect availability at `http://localhost:8765` before invoking Claude.

## Anki Card Structure

### Vocabulary Cards (ff_vocab) - Shared model, all languages
- **Deck**: `{Language}::Vocabulary` (e.g., `French::Vocabulary`, `Swedish::Vocabulary`)
- **Model**: `ff_vocab`
- **Fields**: 39 fields including word, morphology, pronunciation, meanings (target language + English), synonyms, antonyms, variations, confusables, word family, etymology, memory hook, 5 collocations with audio, 3 example usages with audio, and reference link

### Phrase/Meaningblock Cards (ff_meaningblocks) - Shared model, all languages
- **Deck**: `{Language}::Phrases` (e.g., `French::Phrases`, `Swedish::Phrases`)
- **Model**: `ff_meaningblocks`
- **Fields**: 15 fields including phrase, pronunciation, meaning (target language), meaning_translation (English), usage notes, 3 example usages with translations and audio

## Critical Requirements

- Audio filenames MUST use UUID4 to prevent duplication
- Language-specific dictionary must be the authoritative source for definitions and morphology
- Append whitespace to TTS text for natural-sounding audio
- Tags follow hierarchical taxonomy in `.claude/guides/tagging-guide.md`

## Adding a New Language

1. Create `config/languages/{lang}.conf` with voice ID, deck prefix, reference source
2. Create `.claude/commands/ff_vocab_{lang}.md` (adapt from existing language)
3. Create `.claude/commands/ff_meaningblock_{lang}.md`
4. Create `quickactions/ff_{lang}.applescript`
5. Set up macOS Quick Action in Automator
6. No changes needed to `ff_flashcard.sh` - it auto-routes based on `--lang`

## Debugging

Debug logs are written to `/tmp/flashcard.log`. To monitor:
```bash
tail -f /tmp/flashcard.log
```

Test service dependencies:
```bash
./tests/test-service.sh
```
