---
description: Create a French vocabulary Anki flashcard with audio
---

You are tasked with creating an Anki card for the given French word, using **WordReference as the source** for definitions, part of speech, gender/plurals, abbreviations, etc. Do not hallucinate these; if a bit of information (e.g. plural form) is not found on WordReference, say "unknown" for that field.

**Target word:** $ARGUMENTS

---

FIRST, check what MCP tools are available to you. Particularly check for the anki-mcp tools.

Create an Anki card in the deck "French::Vocabulary" for this word.

**IMPORTANT: This command requires the Anki MCP to be available. If the Anki MCP is not available, report this to the user and provide the card content in text format instead.**

**Process:**

1. **Check Anki MCP availability** - Use `mcp__anki-mcp__list_decks` to verify the MCP is working
2. **Research the word** - Use WordReference as the primary source for all information
3. **Create the Anki card** - Use `mcp__anki-mcp__create_note` with:
   - deck_name: "French::Vocabulary"
   - model_name: "ff_vocab"
   - fields: All fields populated with the researched information
   - tags: Apply tags following `.claude/guides/tagging-guide.md` (minimum 4-6 tags per card)
4. **Generate audio** - **MANDATORY:** Use `mcp__anki-mcp__generate_and_save_audio` to create pronunciation audio for:
   - The French word itself
   - All 5 collocations
   - All 3 example usages
   Use provider: "elevenlabs", voice: "JdwJ7jL68CWmQZuo7KgG", language: "fr-FR"
5. **Update the card** - Use `mcp__anki-mcp__update_note` to add all audio filenames to their respective fields

**Anki Details:**
- **Model:** Use "ff_vocab" (specific fields as detailed below)
- **Deck:** "French::Vocabulary"
- **Fields:** Each field corresponds to the detailed information structure below
- **Tags:** Follow `.claude/guides/tagging-guide.md` — must include Type::, Grammar::, Topic::, Level::, and any applicable Note:: tags

**Additional Requirements:**

- **MCP Fallback:** If Anki MCP is not available, provide all the information in a structured text format and inform the user
- Decide CEFR listening difficulty roughly based on how frequent and basic the word is in daily spoken French (use WR's indication of frequency if available).
- Ensure WordReference is referenced (real definitions / abbreviations / genders etc). Do *not* invent.
- If WordReference gives multiple translations, pick the most common ones.
- Always include variations (singular/plural, masc/fem) if applicable.
- **Gender Handling**: For adjectives and adverbs, use the MASCULINE form as the primary entry in the "Word" field. If the user provides a feminine form, use discretion to revert to the masculine form as the main entry. Always include the feminine form in the "Variations" section.
- Consult WordReference thoughtfully rather than scraping; register and nuances must be captured only where explicitly indicated in WordReference.

- **Audio File Naming** CRITICAL: The audio filenames MUST be generated using a UUID4 for EVERY audio file to prevent duplication and confusion. Each audio file must have a unique UUID4 filename in the format: {uuid}.mp3. This applies to ALL audio files: word pronunciation, collocations, and example usages. Do NOT reuse filenames or use generic names.

- **Audio Field Format** IMPORTANT: All audio fields must contain the plain filename (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890.mp3") wrapped inside [sound:<full_file_name.mp3>] tags.

- **Audio Transcriptions** In EVERY audio transcription append a white space to the end of the text to be transcribed (this will help with making the transcription sound natural).

**Field Mapping (use these exact field names in the Anki card):**

1. **Word:** [the French headword, lowercase] - For adjectives and adverbs, use the MASCULINE form as the primary entry. If the user provides a feminine form, use discretion to revert to the masculine form as the main entry.

2. **Morpho:** [compact line using WordReference-style abbreviations, including part of speech, gender, singular/plural, and where applicable verbal principal forms or variation; e.g. "nm; pl: -s", "nf inv", "vtr, vi; pp: tenu; fut: je tiendrai", "adj; f: -e; mpl: -s" etc. If something (like plural) is not listed in WordReference, say "unknown".]

3. **Pronunciation:** [friendly respelling] | [IPA] — from WordReference or trustworthy source; if IPA not given, leave IPA blank.

4. **word_audio:** Use ONLY the plain filename: "{uuid}.mp3" where {uuid} is a UUID4 generated for this specific audio file wrapped in [sound:] tags.

5. **meaning:** [common meanings in french] - Provide up to 6 definitions for the word, ordered from most to least common. Each definition should be concise and relevant. Attempt to give synonyms, or super brief descriptions in french, in such a manner as to assist with word association. If WordReference marks register/nuance (e.g., vulgar, literary, informal) for a specific translation sense, include it in parentheses next to that sense.

6. **meaning_translation:** [English translations corresponding to the French meanings above] - Provide English translations for each of the French meanings listed in the "meaning" field, in the same order.

7. **Synonyms:** 3–8 French synonyms (everyday ones; from WR if possible; if not known, say "unknown")

8. **Antonyms:** up to 3

9. **Variations:** singular/plural, masculine/feminine form(s), if applicable (from WordReference). For adjectives and adverbs, always include the feminine form here even if the main entry is masculine.

10. **Confusables:** French words often confused with the target word, with a short hint; if none clearly in WR or usage sources.
(<short hint about meaning) — how <confusable-word> differs from target word. Specifically think of words that are spelt similar, sounds similar or 'false friends'.

11. **Word_Family:** 3–10 morphologically related French words (derivatives or compounds) if available; else "unknown"

12. **Etymology:** one short line: origin (if known from WR or reliable sources)

13. **memory_hook:** A simple language-based memory hook specifically aimed at english speakers, look for something in the word, some sound or similarity to a similar idea in english. Failing that try some imagery.

---

NB: for each of the following collocations, specifically look for commonly found usages and those that change the sound of the word. Each should be very short, up to 4 words maximum.

14. **collocation_1:** [collocation in french]
15. **collocation_1_translation:** [translation of the collocation]
16. **collocation_1_audio:** [sound:{uuid}.mp3]

17. **collocation_2:** [collocation in french]
18. **collocation_2_translation:** [translation of the collocation]
19. **collocation_2_audio:** [sound:{uuid}.mp3]

20. **collocation_3:** [collocation in french]
21. **collocation_3_translation:** [translation of the collocation]
22. **collocation_3_audio:** [sound:{uuid}.mp3]

23. **collocation_4:** [collocation in french]
24. **collocation_4_translation:** [translation of the collocation]
25. **collocation_4_audio:** [sound:{uuid}.mp3]

26. **collocation_5:** [collocation in french]
27. **collocation_5_translation:** [translation of the collocation]
28. **collocation_5_audio:** [sound:{uuid}.mp3]

---

Example usages should illustrate how the word sounds in context, showing liaison and flow.

29. **example_usage_1:** [example usage in french]
30. **example_usage_1_translation:** [translation of the example usage]
31. **example_usage_1_audio:** [sound:{uuid}.mp3]

32. **example_usage_2:** [example usage in french]
33. **example_usage_2_translation:** [translation of the example usage]
34. **example_usage_2_audio:** [sound:{uuid}.mp3]

35. **example_usage_3:** [example usage in french]
36. **example_usage_3_translation:** [translation of the example usage]
37. **example_usage_3_audio:** [sound:{uuid}.mp3]

---

38. **wr_link:** [complete WordReference link if exists] - do not provide dead links, ensure works correctly.

---

End of instruction.
