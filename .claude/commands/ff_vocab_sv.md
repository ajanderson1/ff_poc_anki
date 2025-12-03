---
description: Create a Swedish vocabulary Anki flashcard with audio
---

You are tasked with creating an Anki card for the given Swedish word, using **WordReference (wordreference.com/sven) as the primary source** for definitions, part of speech, noun class (en/ett), inflections, etc. Do not hallucinate these; if a bit of information is not found on WordReference, say "unknown" for that field.

**Target word:** $ARGUMENTS

---

FIRST, check what MCP tools are available to you. Particularly check for the anki-mcp tools.

Create an Anki card in the deck "Swedish::Vocabulary" for this word.

**IMPORTANT: This command requires the Anki MCP to be available. If the Anki MCP is not available, report this to the user and provide the card content in text format instead.**

**Process:**

1. **Check Anki MCP availability** - Use `mcp__anki-mcp__list_decks` to verify the MCP is working
2. **Research the word** - Use WordReference (wordreference.com/sven) as the primary source for all information
3. **Create the Anki card** - Use `mcp__anki-mcp__create_note` with:
   - deck_name: "Swedish::Vocabulary"
   - model_name: "ff_vocab"
   - fields: All fields populated with the researched information
   - tags: Apply tags following `.claude/guides/tagging-guide.md` (minimum 4-6 tags per card)
4. **Generate audio** - **MANDATORY:** Use `mcp__anki-mcp__generate_and_save_audio` to create pronunciation audio for:
   - The Swedish word itself
   - All 5 collocations
   - All 3 example usages
   Use provider: "elevenlabs", voice: "4Ct5uMEndw4cJ7q0Jx0l", language: "sv-SE"
5. **Update the card** - Use `mcp__anki-mcp__update_note` to add all audio filenames to their respective fields

**Anki Details:**
- **Model:** Use "ff_vocab" (specific fields as detailed below)
- **Deck:** "Swedish::Vocabulary"
- **Fields:** Each field corresponds to the detailed information structure below
- **Tags:** Follow `.claude/guides/tagging-guide.md` — must include Type::, Grammar::, Topic::, Level::, and any applicable Note:: tags

**Additional Requirements:**

- **MCP Fallback:** If Anki MCP is not available, provide all the information in a structured text format and inform the user
- Decide CEFR listening difficulty roughly based on how frequent and basic the word is in daily spoken Swedish.
- Ensure WordReference is referenced (real definitions / inflections / noun classes etc). Do *not* invent.
- If WordReference gives multiple translations, pick the most common ones.
- Always include variations (singular/plural, definite/indefinite) if applicable.
- **Swedish Noun Classes**: Swedish nouns are either "en" (common gender) or "ett" (neuter gender). Always indicate this in the Morpho field. Example: "en hund" (common), "ett hus" (neuter).
- **Compound Words**: Swedish commonly forms compound words. If the target word is a compound, note its components in the Etymology or Word_Family field.
- **Definite Forms**: Swedish adds definite articles as suffixes (e.g., hund → hunden, hus → huset). Include these in Variations.
- Consult WordReference thoughtfully; register and nuances must be captured only where explicitly indicated.

- **Audio File Naming** CRITICAL: The audio filenames MUST be generated using a UUID4 for EVERY audio file to prevent duplication and confusion. Each audio file must have a unique UUID4 filename in the format: {uuid}.mp3. This applies to ALL audio files: word pronunciation, collocations, and example usages. Do NOT reuse filenames or use generic names.

- **Audio Field Format** IMPORTANT: All audio fields must contain the plain filename (e.g., "a1b2c3d4-e5f6-7890-abcd-ef1234567890.mp3") wrapped inside [sound:<full_file_name.mp3>] tags.

- **Audio Transcriptions** In EVERY audio transcription append a white space to the end of the text to be transcribed (this will help with making the transcription sound natural).

**Field Mapping (use these exact field names in the Anki card):**

1. **Word:** [the Swedish headword, lowercase]

2. **Morpho:** [compact line including part of speech, noun class (en/ett), and inflection patterns; e.g. "en, -ar" for common gender noun with -ar plural, "ett, -" for neuter noun with no change in plural, "verb, -er, -de, -t" for verb forms, "adj, -t, -a" for adjective forms, etc. If something is not listed in WordReference, say "unknown".]

3. **Pronunciation:** [friendly respelling] | [IPA] — from WordReference or trustworthy source; if IPA not given, leave IPA blank.

4. **word_audio:** Use ONLY the plain filename: "{uuid}.mp3" where {uuid} is a UUID4 generated for this specific audio file wrapped in [sound:] tags.

5. **meaning:** [common meanings in Swedish] - Provide up to 6 definitions for the word, ordered from most to least common. Each definition should be concise and relevant. Attempt to give synonyms, or super brief descriptions in Swedish, in such a manner as to assist with word association. If WordReference marks register/nuance (e.g., informal, formal) for a specific sense, include it in parentheses next to that sense.

6. **meaning_translation:** [English translations corresponding to the Swedish meanings above] - Provide English translations for each of the Swedish meanings listed in the "meaning" field, in the same order.

7. **Synonyms:** 3–8 Swedish synonyms (everyday ones; from WordReference if possible; if not known, say "unknown")

8. **Antonyms:** up to 3

9. **Variations:** Include definite/indefinite forms, singular/plural. For nouns: indefinite singular, definite singular, indefinite plural, definite plural. For adjectives: base form, neuter form (-t), plural/definite form (-a).

10. **Confusables:** Swedish words often confused with the target word, with a short hint; if none clearly in WordReference or usage sources.
(<short hint about meaning) — how <confusable-word> differs from target word. Specifically think of words that are spelt similar, sounds similar or 'false friends' with English.

11. **Word_Family:** 3–10 morphologically related Swedish words (derivatives or compounds) if available; else "unknown". Swedish is rich in compound words, so include relevant compounds.

12. **Etymology:** one short line: origin (if known from WordReference or reliable sources). Note if the word is borrowed from another language.

13. **memory_hook:** A simple language-based memory hook specifically aimed at English speakers, look for something in the word, some sound or similarity to a similar idea in English or German. Failing that try some imagery.

---

NB: for each of the following collocations, specifically look for commonly found usages and those that illustrate typical Swedish word patterns. Each should be very short, up to 4 words maximum.

14. **collocation_1:** [collocation in Swedish]
15. **collocation_1_translation:** [translation of the collocation]
16. **collocation_1_audio:** [sound:{uuid}.mp3]

17. **collocation_2:** [collocation in Swedish]
18. **collocation_2_translation:** [translation of the collocation]
19. **collocation_2_audio:** [sound:{uuid}.mp3]

20. **collocation_3:** [collocation in Swedish]
21. **collocation_3_translation:** [translation of the collocation]
22. **collocation_3_audio:** [sound:{uuid}.mp3]

23. **collocation_4:** [collocation in Swedish]
24. **collocation_4_translation:** [translation of the collocation]
25. **collocation_4_audio:** [sound:{uuid}.mp3]

26. **collocation_5:** [collocation in Swedish]
27. **collocation_5_translation:** [translation of the collocation]
28. **collocation_5_audio:** [sound:{uuid}.mp3]

---

Example usages should illustrate how the word sounds in context, showing typical Swedish sentence structure.

29. **example_usage_1:** [example usage in Swedish]
30. **example_usage_1_translation:** [translation of the example usage]
31. **example_usage_1_audio:** [sound:{uuid}.mp3]

32. **example_usage_2:** [example usage in Swedish]
33. **example_usage_2_translation:** [translation of the example usage]
34. **example_usage_2_audio:** [sound:{uuid}.mp3]

35. **example_usage_3:** [example usage in Swedish]
36. **example_usage_3_translation:** [translation of the example usage]
37. **example_usage_3_audio:** [sound:{uuid}.mp3]

---

38. **wr_link:** [complete WordReference link] - Use the format: https://www.wordreference.com/sven/{word} - do not provide dead links, ensure works correctly.

---

End of instruction.
