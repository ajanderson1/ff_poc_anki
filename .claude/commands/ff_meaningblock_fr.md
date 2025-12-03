---
description: Create a French phrase/expression Anki flashcard with audio
---

You are tasked with creating an Anki card for the given French phrase or expression.

**Target phrase:** $ARGUMENTS

---

FIRST, check what MCP tools are available to you. Particularly check for the anki-mcp tools.

Create an Anki card in the deck "French::Phrases" for this phrase.

**IMPORTANT: This command requires the Anki MCP to be available. If the Anki MCP is not available, report this to the user and provide the card content in text format instead.**

**Process:**

1. **Check Anki MCP availability** - Use `mcp__anki-mcp__list_decks` to verify the MCP is working
2. **Define and translate the phrase** - First, create a French explanation/definition of the phrase using synonyms or brief descriptions. Then translate the phrase to English in the most natural way possible. If it's an expression where there are multiple common ways of expressing it, include both.
3. **Create the Anki card** - Use `mcp__anki-mcp__create_note` with:
   - deck_name: "French::Phrases"
   - model_name: "ff_meaningblocks"
   - fields: All 15 fields populated with the researched information
   - tags: Apply tags following `.claude/guides/tagging-guide.md` (minimum 4-6 tags per card)
4. **Generate audio** - **MANDATORY:** Use `mcp__anki-mcp__generate_and_save_audio` to create pronunciation audio for:
   - The French phrase itself
   - All 3 example usages
   Use provider: "elevenlabs", voice: "JdwJ7jL68CWmQZuo7KgG", language: "fr-FR"
5. **Update the card** - Use `mcp__anki-mcp__update_note` to add all audio filenames to their respective fields

**Anki Details:**
- **Model:** Use "ff_meaningblocks" (has 15 specific fields as detailed below)
- **Deck:** "French::Phrases"
- **Fields:** Each field corresponds to the detailed information structure below
- **Tags:** Follow `.claude/guides/tagging-guide.md` — must include Type::, Topic::, Level::, Register::, and any applicable Note:: tags. NB: no whitespace in tags

**Additional Requirements:**

- **MCP Fallback:** If Anki MCP is not available, provide all the information in a structured text format and inform the user
- Decide CEFR listening difficulty roughly based on how frequent and basic the phrase is in daily spoken French.

- **Audio File Naming** CRITICAL: The audio filenames MUST be generated using a UUID4 for EVERY audio file to prevent duplication and confusion. Each audio file must have a unique UUID4 filename in the format: {uuid}.mp3. This applies to ALL audio files: phrase pronunciation and example usages. Do NOT reuse filenames or use generic names.

- **Audio Field Format** IMPORTANT: All audio fields must contain the plain filename (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890.mp3") wrapped inside [sound:<full_file_name.mp3>] tags.

- **Audio Transcriptions** In EVERY audio transcription append a white space to the end of the text to be transcribed (this will help with making the transcription sound natural). Where the text is clearly two speakers, ensure to leave a natural gap between call and response.

**Field Mapping (use these exact field names in the Anki card):**

1. **phrase:** [the French phrase, lowercase]

2. **pronunciation:** [friendly respelling]

3. **meaning:** [French explanation/definition of the phrase] - Provide a concise explanation in French of what the phrase means, using synonyms or brief descriptions to assist with understanding. This should help learners grasp the meaning in French before seeing the English translation.

4. **meaning_translation:** [English translation of the phrase] - Where there are multiple commonly used English translations applicable, list these separated by ` / `.

5. **usage_notes:** [Pertinent notes in English on how it is used, anything to be careful/aware of, etc.]

---

6. **example_usage_1:** [example of how the phrase is typically used in a broader context] This should be a full sentence, not just a fragment.

7. **example_usage_1_translation:** [translation of the example usage] - The most natural translation of the example usage.

8. **example_usage_2:** [example of how the phrase is typically used in a broader context] This should be a full sentence, not just a fragment.

9. **example_usage_2_translation:** [translation of the example usage] - The most natural translation of the example usage.

10. **example_usage_3:** [example of how the phrase is typically used in a broader context] This should be a full sentence, not just a fragment.

11. **example_usage_3_translation:** [translation of the example usage] - The most natural translation of the example usage.

---

12. **phrase_audio:** [sound:{uuid}.mp3] where {uuid} is a UUID4 generated for this specific audio file.

13. **example_usage_1_audio:** [sound:{uuid}.mp3] where {uuid} is a UUID4 generated for this specific audio file.

14. **example_usage_2_audio:** [sound:{uuid}.mp3] where {uuid} is a UUID4 generated for this specific audio file.

15. **example_usage_3_audio:** [sound:{uuid}.mp3] where {uuid} is a UUID4 generated for this specific audio file.

---

End of instruction.
