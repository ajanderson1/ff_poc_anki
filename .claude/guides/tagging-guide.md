# Language Learning Flashcard Tagging Guide

Apply relevant tags from the categories below. Each card should have **4-6 tags minimum**. Use the hierarchical format shown (e.g., `Type::Vocabulary`, `Grammar::Noun::Masculine`).

---

## 1. TYPE (How the language unit is structured)
- `Type::Vocabulary` — Single word
- `Type::Phrase` — Collocation or short grouping (2-4 words)
- `Type::Sentence` — Full sentence with context
- `Type::Idiom` — Figurative or non-literal meaning
- `Type::Expression` — Fixed expression or saying
- `Type::Proverb` — Traditional saying with wisdom

## 2. REGISTER (Formality and social context)
- `Register::Formal` — Polite, business, official contexts
- `Register::Neutral` — Standard, everyday language
- `Register::Casual` — Friends, informal settings
- `Register::Slang` — Very informal, generational
- `Register::Vulgar` — Swear words, insults, offensive
- `Register::Literary` — Poetic, archaic, written only
- `Register::Technical` — Specialized professional jargon

## 3. GRAMMAR (Word class and grammatical features)
- `Grammar::Noun::Masculine`
- `Grammar::Noun::Feminine`
- `Grammar::Verb::Transitive` — Takes direct object
- `Grammar::Verb::Intransitive` — No direct object
- `Grammar::Verb::Reflexive` — Acts on itself
- `Grammar::Verb::Irregular` — Irregular conjugation
- `Grammar::Verb::Phrasal` — Verb + particle(s)
- `Grammar::Adjective`
- `Grammar::Adverb`
- `Grammar::Preposition`
- `Grammar::Conjunction`
- `Grammar::Pronoun`
- `Grammar::Interjection`
- `Grammar::Article`
- `Grammar::Particle`

## 4. TOPIC (Semantic domain/subject matter)
- `Topic::Daily_Routine` — Waking, showering, chores, habits
- `Topic::Food_and_Dining` — Ingredients, cooking, restaurants, ordering
- `Topic::Travel_and_Transport` — Directions, vehicles, tickets, accommodation
- `Topic::Social_and_Family` — Friends, relatives, relationships, gatherings
- `Topic::Work_and_Education` — Office, school, careers, studying
- `Topic::Health_and_Body` — Body parts, illness, medicine, fitness
- `Topic::Emotions_and_Abstract` — Feelings, psychological states, time, ideas
- `Topic::Nature_and_Environment` — Weather, animals, plants, geography
- `Topic::Home_and_Household` — Furniture, appliances, rooms, maintenance
- `Topic::Clothing_and_Appearance` — Fashion, accessories, style, grooming
- `Topic::Technology_and_Computing` — Digital, devices, internet, software
- `Topic::Money_and_Shopping` — Banking, purchases, prices, commerce
- `Topic::Sports_and_Hobbies` — Exercise, recreation, pastimes, games
- `Topic::Entertainment_and_Media` — Movies, music, books, art
- `Topic::Politics_and_News` — Government, current events, society
- `Topic::Time_and_Calendar` — Dates, seasons, schedules, duration

## 5. FREQUENCY & DIFFICULTY
- `Frequency::High` — Very common, everyday use
- `Frequency::Common` — Regularly encountered
- `Frequency::Uncommon` — Specialized or less frequent
- `Frequency::Rare` — Seldom used, archaic

- `Level::A1` / `Level::A2` — Beginner
- `Level::B1` / `Level::B2` — Intermediate
- `Level::C1` / `Level::C2` — Advanced

## 6. LEARNING NOTES (Special attention markers)
- `Note::Essential` — Core vocabulary, high priority
- `Note::Confusing` — Easily mixed up or misunderstood
- `Note::False_Friend` — Similar to English word but different meaning
- `Note::Cognate` — Similar to English word with same meaning
- `Note::Exception` — Breaks normal rules
- `Note::Tricky` — Difficult pronunciation, spelling, or usage

## 7. USAGE CONTEXT
- `Usage::Spoken` — Primarily oral communication
- `Usage::Written` — Primarily written communication
- `Usage::Both` — Equally used in speech and writing
- `Usage::Regional` — Specific to certain areas/dialects

---

## TAGGING REQUIREMENTS

1. **Minimum tags**: Always include at least one Type, one Grammar (if applicable), one Topic, and one Level tag
2. **Be specific**: Use subcategories when they exist (e.g., `Grammar::Verb::Irregular` not just `Grammar::Verb`)
3. **Mark special cases**: Always flag false friends, confusing items, and exceptions with Note:: tags
4. **Register matters**: Default to `Register::Neutral` if unmarked; always tag non-neutral register

---

## EXAMPLES

**Card: "soutien" (support)**
```
Type::Vocabulary
Grammar::Noun::Masculine
Topic::Social_and_Family
Topic::Emotions_and_Abstract
Register::Neutral
Frequency::High
Level::B1
```

**Card: "c'est-à-dire" (that is to say)**
```
Type::Expression
Topic::Work_and_Education
Register::Neutral
Usage::Both
Frequency::High
Level::A2
Note::Essential
```

**Card: "avoir le cafard" (to feel down/blue)**
```
Type::Idiom
Grammar::Verb::Transitive
Topic::Emotions_and_Abstract
Register::Casual
Usage::Spoken
Frequency::Common
Level::B2
Note::Confusing
```
