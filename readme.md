# Chinese Learning with Anki

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

## Learning Structure

### Level 1
1-2 characters long, building up to 3-4 characters based on previously learned components

### Level 2
Build 5+ character phrases from Level 1 components

## Project Structure

```
decks/
├── electronic-girl/          # Electronic Girl by Chinese Football
│   ├── *.json               # Lesson configuration files
│   ├── *.txt                # Lyrics files
│   └── audio/               # Generated TTS audio files
└── my-little-apple/          # Future: My Little Apple by Chopstick Brothers
```

## Adding New Words

To add new vocabulary to lesson files:
```json
  "front": "[sound:new_word.mp3]",  // or just "新词" for reading
  "back": "新词 (xīn cí)<br><br>new word<br><br><i>Context...</i>",
  "tags": ["word", "noun"],
  "audioFile": "new_word.mp3",
  "chineseText": "新词"
}
```