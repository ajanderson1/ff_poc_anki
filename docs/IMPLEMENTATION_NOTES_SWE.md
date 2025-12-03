# Implementation Notes: Multi-Language Flashcard System (Swedish Support)

**Date:** 2025-12-01
**Scope:** Extend French-only flashcard system to support multiple languages, with Swedish as first additional language

---

## Objective

Transform the existing French-only Anki flashcard generation system into a multi-language architecture that:
1. Minimizes code duplication
2. Uses a single unified entry point
3. Shares Anki models across languages
4. Makes adding future languages straightforward

---

## Architecture Decisions

### 1. Single Entry Point with Language Parameter
**Decision:** Replace `ff_french.sh` with `ff_flashcard.sh --lang=XX`

**Rationale:** Centralizes all pre-flight checks (Anki running, AnkiConnect responsive) and routing logic in one place. Language-specific behavior is loaded from configuration files.

### 2. Language Configuration Files
**Decision:** Store language-specific settings in `config/languages/{lang}.conf`

**Contents per language:**
- `LANG_CODE` - 2-letter code (fr, sv)
- `LANG_NAME` - Display name (French, Swedish)
- `LANG_TTS_CODE` - ElevenLabs language code (fr-FR, sv-SE)
- `LANG_VOICE_ID` - ElevenLabs voice identifier
- `LANG_DECK_PREFIX` - Anki deck naming (French, Swedish)
- `LANG_REFERENCE` - Dictionary source name
- `LANG_REFERENCE_URL` - Dictionary base URL

### 3. Per-Language Slash Commands
**Decision:** Create separate slash commands per language (`/ff_vocab_sv`, `/ff_meaningblock_sv`)

**Rationale:** Claude Code slash commands are prompt templates that cannot dynamically read configuration files. Each language needs its own command with hardcoded voice IDs, deck names, and language-specific instructions (e.g., Swedish en/ett noun classes vs French masculine/feminine).

### 4. Shared Anki Models
**Decision:** Use the same `ff_vocab` and `ff_meaningblocks` models for all languages

**Rationale:** The field structure (Word, Morpho, Pronunciation, meaning, etc.) is language-agnostic. Only the deck names change per language (`French::Vocabulary` vs `Swedish::Vocabulary`).

### 5. Language-Neutral Templates
**Decision:** Update Anki card templates to use English labels instead of French

**Changes:**
- `Principales traductions` → `Meaning`
- `Sens` → `Meaning`

---

## Files Created

| File | Purpose |
|------|---------|
| `ff_flashcard.sh` | Unified entry point script with `--lang=XX` parameter |
| `config/languages/french.conf` | French language configuration |
| `config/languages/swedish.conf` | Swedish language configuration |
| `.claude/commands/ff_vocab_sv.md` | Swedish vocabulary flashcard command |
| `.claude/commands/ff_meaningblock_sv.md` | Swedish phrase flashcard command |
| `.claude/guides/vocab-field-guide.md` | Shared field structure documentation |
| `.claude/guides/audio-generation-guide.md` | Shared TTS generation instructions |
| `quickactions/ff_french.applescript` | macOS Quick Action wrapper for French |
| `quickactions/ff_swedish.applescript` | macOS Quick Action wrapper for Swedish |

## Files Modified

| File | Change |
|------|--------|
| `templates/vocab_card/default/card_back_all.html` | Changed "Principales traductions" → "Meaning" |
| `templates/meaningblock_card/default/card_back_all.html` | Changed "Sens" → "Meaning" |
| `CLAUDE.md` | Updated to reflect multi-language architecture |

## Files Moved to `deprecated/`

| File | Reason |
|------|--------|
| `ff_french.sh` | Replaced by unified `ff_flashcard.sh` |
| `ff_french.applescript` | Replaced by `quickactions/ff_french.applescript` |

---

## Swedish-Specific Implementation Details

### Dictionary Source
**Lexin** (lexin.nada.kth.se) - Swedish Academy's learner-focused dictionary with:
- Clear definitions in Swedish
- English translations
- Inflection patterns
- Audio pronunciations (reference only, we generate our own)

### TTS Voice
**Elin** (ID: `4Ct5uMEndw4cJ7q0Jx0l`)
- Female, young voice
- Clear instructional tone
- Optimized for e-learning
- Standard Swedish accent (not regional)

### Grammar Adaptations
The Swedish vocabulary command includes specific handling for:

1. **Noun Classes**: Swedish uses en/ett (common/neuter) instead of French masculine/feminine
   - Example Morpho: `en, -ar` (common gender, -ar plural)
   - Example Morpho: `ett, -` (neuter gender, no plural change)

2. **Definite Articles as Suffixes**: Unlike French, Swedish adds definite articles as suffixes
   - Variations field includes: indefinite singular, definite singular, indefinite plural, definite plural
   - Example: hund, hunden, hundar, hundarna

3. **Compound Words**: Swedish extensively uses compound words
   - Word_Family field explicitly notes compound word components
   - Example: sjukhus (sjuk + hus = sick + house = hospital)

4. **No Adjective Gender Agreement**: Removed French-specific adjective gender rules
   - Swedish adjectives inflect for neuter (-t) and plural/definite (-a)
   - Example Variations: stor, stort, stora

---

## Usage

### Command Line
```bash
# Swedish vocabulary card
./ff_flashcard.sh --lang=sv "hund"

# Swedish phrase card
./ff_flashcard.sh --lang=sv "hur mår du"

# French vocabulary card (still works)
./ff_flashcard.sh --lang=fr "bonjour"
```

### macOS Quick Actions
After setting up in Automator:
1. Select Swedish text anywhere
2. Right-click → Services → "Swedish Flashcard"
3. Card is automatically created with audio

---

## Required Anki Setup

Before using Swedish flashcards, create the following decks in Anki:
- `Swedish::Vocabulary`
- `Swedish::Phrases`

The existing `ff_vocab` and `ff_meaningblocks` models will be used automatically.

---

## Adding Future Languages

To add another language (e.g., German):

1. **Create configuration file**
   ```bash
   # config/languages/german.conf
   LANG_CODE="de"
   LANG_NAME="German"
   LANG_TTS_CODE="de-DE"
   LANG_VOICE_ID="<find German voice on ElevenLabs>"
   LANG_DECK_PREFIX="German"
   LANG_REFERENCE="Duden"
   LANG_REFERENCE_URL="https://www.duden.de/rechtschreibung/"
   ```

2. **Create slash commands**
   - Copy `ff_vocab_sv.md` → `ff_vocab_de.md`
   - Adapt for German grammar (cases, noun genders, etc.)
   - Update deck names, voice ID, reference source
   - Same process for `ff_meaningblock_de.md`

3. **Create Quick Action**
   - Copy `quickactions/ff_swedish.applescript` → `quickactions/ff_german.applescript`
   - Change `--lang=sv` to `--lang=de`
   - Update notification titles

4. **Create Anki decks**
   - `German::Vocabulary`
   - `German::Phrases`

No changes required to `ff_flashcard.sh` - it automatically routes based on the `--lang` parameter.

---

## Testing Checklist

- [ ] `./ff_flashcard.sh --lang=sv "hej"` creates vocabulary card
- [ ] `./ff_flashcard.sh --lang=sv "god morgon"` creates phrase card
- [ ] `./ff_flashcard.sh --lang=fr "bonjour"` still works (regression test)
- [ ] Audio files are generated with UUID filenames
- [ ] Cards appear in correct decks (`Swedish::Vocabulary`, `Swedish::Phrases`)
- [ ] Lexin is consulted for Swedish definitions
- [ ] macOS Quick Actions work after Automator setup

---

## Known Limitations

1. **No auto-detection**: Language must be explicitly specified via `--lang` parameter
2. **Shared models**: All languages use the same field structure; language-specific fields (like French liaison notes) may not apply to all languages
3. **Reference link field**: Named `wr_link` (WordReference legacy) but used for any dictionary link

---

## Debugging

Logs are written to `/tmp/flashcard.log`:
```bash
tail -f /tmp/flashcard.log
```

Log includes:
- Language loaded
- Input text
- Word count
- Which slash command was invoked
- Success/failure status
