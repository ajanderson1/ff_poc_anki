# Audio Generation Guide

This guide documents the audio generation process for Anki flashcards using the MCP tools.

## MCP Tool Usage

Use `mcp__anki-mcp__generate_and_save_audio` for all audio generation.

### Parameters

```
provider: "elevenlabs"
voice: <language-specific voice ID>
language: <language-specific code>
text: <text to transcribe>
filename: <uuid>.mp3
```

### Language-Specific Voice Configuration

| Language | Voice ID | Language Code | Voice Name |
|----------|----------|---------------|------------|
| French | `JdwJ7jL68CWmQZuo7KgG` | `fr-FR` | (default French voice) |
| Swedish | `4Ct5uMEndw4cJ7q0Jx0l` | `sv-SE` | Elin (clear instructional) |

## Critical Requirements

### 1. UUID4 Filenames (MANDATORY)

Every audio file MUST use a unique UUID4 filename to prevent:
- Filename collisions between cards
- Overwriting existing audio files
- Confusion in the Anki media collection

**Correct:** `a1b2c3d4-e5f6-7890-abcd-ef1234567890.mp3`
**Wrong:** `word.mp3`, `example1.mp3`, `french_bonjour.mp3`

### 2. Audio Field Format

All audio fields must use the Anki sound tag format:

```
[sound:a1b2c3d4-e5f6-7890-abcd-ef1234567890.mp3]
```

### 3. Whitespace Padding

**IMPORTANT:** Append a whitespace character to the END of every transcription text.

This ensures natural-sounding audio by:
- Preventing abrupt cutoffs
- Allowing proper sentence-final intonation
- Creating a brief pause at the end

**Example:**
```
text: "Bonjour, comment allez-vous? "  ← Note trailing space
```

### 4. Multi-Speaker Content

For dialogue or call-and-response content:
- Leave a natural gap between speakers in the text
- Consider generating separate audio files if needed

## Workflow

### Vocabulary Cards (9 audio files)

1. **Word pronunciation** → `word_audio`
2. **Collocation 1** → `collocation_1_audio`
3. **Collocation 2** → `collocation_2_audio`
4. **Collocation 3** → `collocation_3_audio`
5. **Collocation 4** → `collocation_4_audio`
6. **Collocation 5** → `collocation_5_audio`
7. **Example 1** → `example_usage_1_audio`
8. **Example 2** → `example_usage_2_audio`
9. **Example 3** → `example_usage_3_audio`

### Phrase Cards (4 audio files)

1. **Phrase pronunciation** → `phrase_audio`
2. **Example 1** → `example_usage_1_audio`
3. **Example 2** → `example_usage_2_audio`
4. **Example 3** → `example_usage_3_audio`

## Process Order

1. **Create card first** using `mcp__anki-mcp__create_note`
   - This returns the `note_id` needed for updates
   - Leave audio fields empty initially

2. **Generate all audio files** using `mcp__anki-mcp__generate_and_save_audio`
   - Generate each file with a unique UUID
   - Track the filename for each field

3. **Update card with audio** using `mcp__anki-mcp__update_note`
   - Pass all audio fields in a single update
   - Use the `[sound:filename.mp3]` format

## Error Handling

If audio generation fails:
1. Report the error to the user
2. Continue with remaining audio files
3. Note which audio fields are missing in the final response
4. The card will still be usable without audio
