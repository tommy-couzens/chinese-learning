
# Chinese Learning with Anki (Original)

A PowerShell module for creating Anki decks from Chinese songs using anki-connect API.

## Quick Start

```powershell
# Import the module
Import-Module ./AnkiDeckFromSongs

# Create Electronic Girl deck
New-AnkiDeck -SongName "electronic-girl"

# Create deck with audio regeneration
New-AnkiDeck -SongName "electronic-girl" -RegenerateAudio

# List available songs
ls decks/
```

## Requirements

- Anki with anki-connect add-on: https://git.sr.ht/~foosoft/anki-connect
- PowerShell (`pwsh` command)

## Project Structure

```
decks/
├── electronic-girl/          # Electronic Girl by Chinese Football
│   ├── *.json               # Lesson configuration files
│   ├── *.txt                # Lyrics files
│   └── audio/               # Generated TTS audio files
└── my-little-apple/          # Future: My Little Apple by Chopstick Brothers
    └── subdecks/            # LLM generated JSON files will be placed here
        └── 1chorus.json     # Example of an LLM-generated file
```

# Guide for Card Generation

This document provides guidelines to assist in creating Anki flashcards from Chinese song lyrics. The goal is to generate structured JSON data that can be used by the accompanying PowerShell module.

## Core Task: Card Data Generation

Given a portion of Chinese song lyrics (e.g., a chorus, a verse), the goal is to generate a JSON object representing Anki cards. This JSON should conform to the structure detailed in the "Output JSON Structure" section below.

## Input for Card Generation

1.  **Song Lyrics**: Plain text of the Chinese song lyrics, including Pinyin and English translation if available.
    *   Example:
        ```
        你是我的小呀小苹果儿 怎么爱你都不嫌多
        nǐ shì wǒ de xiǎo ya xiǎo píngguǒr, zěnme ài nǐ dōu bù xiánduō
        You are my little apple, I can never love you too much
        ```
2.  **Target Section**: The specific part of the song to create cards for (e.g., "Chorus", "Verse 1", "Bridge"). This will be used for the `deckInfo.name` and `deckInfo.level`.

## Output JSON Structure

The process generates a JSON object. The primary components are `deckInfo` and `conceptGroups`.

### 1. `deckInfo` Object

*   `name`: A descriptive name for the Anki subdeck (e.g., "Chinese Learning - My Little Apple - Chorus v1").
*   `description`: A brief description of the deck's content.
*   `level`: The song section (e.g., "Chorus", "IntroVerse1").
*   `type`: Typically "mixed".
*   `cardTemplates`: Usually `["listening", "chinese-reading", "english-reading"]`.

Example `deckInfo`:
```json
{
  "deckInfo": {
    "name": "Chinese Learning - My Little Apple - Chorus v1",
    "description": "Covers Level 1 (characters & small words), Level 2 (phrases) for the Chorus of My Little Apple.",
    "level": "Chorus",
    "type": "mixed",
    "cardTemplates": ["listening", "chinese-reading", "english-reading"]
  }
}
```

### 2. `conceptGroups` Array

This array contains objects, each representing a group of related vocabulary cards. Each group typically focuses on:
*   Introducing a core multi-character word.
*   Introducing individual characters that form a word (if those characters are useful to learn standalone).
*   Reviewing phrases.

Each object in `conceptGroups` has:
*   `groupName`: A descriptive name for the concept group (e.g., "L1/L2: Word - 苹果 (píngguǒ) - apple", "L1: Building 怎么 (zěnme) - how?").
*   `description`: A brief description of the group's focus.
*   `vocabulary`: An array of vocabulary card objects.

### 3. `vocabulary` Array (Card Definition)

Each object in the `vocabulary` array defines a single Anki card and must contain the following fields:

```json
{
  "name": "AUDIO_FILE_NAME_PINYIN_TONE_NUMBERS", // e.g., "ping2guo3", "zen3me"
  "pinyin": "PINYIN_WITH_TONE_MARKS",           // e.g., "píngguǒ", "zěnme"
  "chineseText": "CHINESE_CHARACTERS",           // e.g., "苹果", "怎么"
  "englishText": "ENGLISH_TRANSLATION",          // e.g., "apple", "how?, what?, why?"
  "explanation": "EXPLANATION_TEXT"              // See guidelines below
}
```

## Card Generation Principles (Learning Structure)

Organize vocabulary into levels within `conceptGroups`.

### Level 1: Foundational Characters & Simple Words
*   **Focus**: Single characters or simple 2-character words.
*   **Progression**: Can build up to 3-4 character words if components were previously introduced or are simple.
*   **Example `groupName`**: "L1: Core Character - 忽 (hū)", "L1: Building 忽近忽远 (hū jìn hū yuǎn)"

### Level 2: Short Phrases
*   **Focus**: Short, meaningful phrases, typically 3-5 characters long.
*   **Example `groupName`**: "L2: Intro/Verse 1 Phrases Review"

### Level 3: Longer Phrases/Simplified Lines (Use with Caution)
*   **Original Intent**: Complete lines of the song.
*   **IMPORTANT**: Avoid creating overly long or complex cards.
    *   If a full song line is too long, break it down into multiple Level 2 phrases.
    *   Prioritize learnable units over complete sentence transcription.
    *   **Example of what to break down**: "春天和你漫步在盛开的花丛间" (In the spring, I stroll with you through the flowers) should be broken into smaller phrases like:
        *   "春天" (In the spring)
        *   "和你漫步" (I stroll with you)
        *   "花丛间" (through the flowers)

## Content Rules for Vocabulary Cards

### 1. Word Granularity
*   **Compound Words**: Introduce directly. Do NOT break down words like "苹果" (píngguǒ) into "苹" and "果" as separate cards if the individual characters are not meaningful standalone words in the context of learning.
*   **Common Multi-Character Words**: Introduce words like "怎么" (zěnme) as a single card. Do NOT create separate cards for "怎" and "么" unless they are also useful standalone words with distinct meanings relevant to the learning context.

### 2. Exclusion of Basic/Known Words
*   Do NOT create cards for very basic or common words that the learner is likely to know.
*   Refer to the file `AnkiDeckFromSongs/known-words.json` for a list of words to exclude.
    *   Examples from `known-words.json`: "不" (no), "我" (me), "你" (you), "好" (good), "她" (she/her), "的" (particle), "在" (at/in/on).

### 3. `explanation` Field Guidelines
The `explanation` field is crucial for context.
*   **Character Breakdown**: If a word comprises multiple characters, explain the meaning of individual characters if it aids understanding (e.g., for "怎么爱你": "'怎么 (zěnme)' - how; '爱 (ài)' - to love; '你 (nǐ)' - you.").
*   **Grammar Notes**: Briefly explain relevant grammar points (e.g., "Adjective reduplication '红红 (hóng hóng)' emphasizes the color red.").
*   **Source Lyric**: Always state which lyric line the word/phrase originates from (e.g., "From the lyric '怎么爱你都不嫌多'.").
*   **Clarity and Conciseness**:
    *   If a helpful and concise explanation incorporating the above points cannot be formulated, leave the `explanation` field empty.
    *   AVOID generic or unhelpful explanations like "Phrase from chorus."

## Card Types (Contextual Information)

The system supports different card types (listening, reading), which is defined in `deckInfo.cardTemplates`. The vocabulary JSON itself does not need to specify the card type directly.
*   **Listening Cards**: Audio on the front, Chinese characters and English translation on the back.
*   **Reading Cards**: Chinese characters on the front, English translation and audio on the back.
