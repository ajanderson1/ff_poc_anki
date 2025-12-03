# Vocabulary Card Field Guide

This guide documents the field structure for vocabulary flashcards across all languages. The `ff_vocab` model uses these 39 fields.

## Field Structure

### Core Word Information (Fields 1-4)
| Field | Description |
|-------|-------------|
| **Word** | The headword in the target language, lowercase |
| **Morpho** | Compact morphological notation (part of speech, gender/class, inflection patterns) |
| **Pronunciation** | Friendly respelling \| IPA transcription |
| **word_audio** | Audio file reference: `[sound:{uuid}.mp3]` |

### Meanings (Fields 5-6)
| Field | Description |
|-------|-------------|
| **meaning** | Up to 6 definitions in the target language, most to least common. Include register notes in parentheses. |
| **meaning_translation** | English translations corresponding to each meaning above, in same order |

### Lexical Relations (Fields 7-11)
| Field | Description |
|-------|-------------|
| **Synonyms** | 3-8 synonyms in target language |
| **Antonyms** | Up to 3 antonyms |
| **Variations** | Inflected forms (singular/plural, gender variations, etc.) |
| **Confusables** | Similar words that are easily confused, with disambiguation hints |
| **Word_Family** | 3-10 morphologically related words (derivatives, compounds) |

### Etymology & Memory (Fields 12-13)
| Field | Description |
|-------|-------------|
| **Etymology** | One-line origin/history |
| **memory_hook** | Mnemonic device for English speakers |

### Collocations (Fields 14-28)
Five collocations, each with:
- **collocation_N** - Short phrase (max 4 words) showing common usage
- **collocation_N_translation** - English translation
- **collocation_N_audio** - Audio file: `[sound:{uuid}.mp3]`

### Example Usages (Fields 29-37)
Three examples, each with:
- **example_usage_N** - Full sentence in target language
- **example_usage_N_translation** - Natural English translation
- **example_usage_N_audio** - Audio file: `[sound:{uuid}.mp3]`

### Reference Link (Field 38)
| Field | Description |
|-------|-------------|
| **wr_link** | Link to authoritative dictionary source |

## Audio Requirements

1. **UUID4 Filenames**: Every audio file must have a unique UUID4 filename
2. **Format**: `[sound:{uuid}.mp3]`
3. **Whitespace**: Append a space to transcription text for natural-sounding audio
4. **Total Audio Files**: 9 per card (1 word + 5 collocations + 3 examples)

## Language-Specific Notes

### French (fr)
- Use WordReference as authoritative source
- Adjectives/adverbs: Use masculine form as primary entry
- Include liaison information in collocations

### Swedish (sv)
- Use Lexin as authoritative source
- Indicate en/ett noun class in Morpho
- Include definite/indefinite forms in Variations
- Note compound word components in Word_Family

## Tagging Requirements

All cards must include minimum 4-6 tags following `.claude/guides/tagging-guide.md`:
- Type:: (Vocabulary, Phrase, Idiom, etc.)
- Grammar:: (Noun::Masculine, Verb::Transitive, etc.)
- Topic:: (Food_and_Dining, Travel, etc.)
- Level:: (A1, A2, B1, B2, C1, C2)
- Register:: (if non-neutral)
- Note:: (for special cases like false friends)
