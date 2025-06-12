# Just provide a list like

I want the listening card to be as good as I have before and include on the back:
The Characters and the pinyin
the translation in english
the meaning of each character

for example:

永远 (yǒngyuǎn)

forever, always

永 + 远 = eternal + far


# I want to seperate the data for the cards and the card contents
I want to have a folder like
card-templates/reading.json
card-templates/listening.json

which are the card templates, and they get populated by teh values of each charater

so before we would have this card:

```json
        {
          "front": "[sound:feng1.mp3]",
          "back": "风<br><br>wind",
          "tags": ["nature", "weather"],
          "audioFile": "feng1.mp3",
          "chineseText": "风",
          "englishText": "wind"
        },
        {
          "front": "[sound:yong_yuan.mp3]",
          "back": "永远 (yǒngyuǎn)<br><br>forever, always<br><br><i>永 + 远 = eternal + far</i>",
          "tags": ["word", "adverb", "time"],
          "audioFile": "yong_yuan.mp3",
          "chineseText": "永远"
        },
```

instead, we would have this data:


```json
{
    "name": "feng1",
    "pinyin": "fēng",
    "chineseText": "风",
    "englishText": "wind",
    "explanation": ""
},
{
    "name": "yong_yuan",
    "pinyin": "yǒngyuǎn",
    "chineseText": "永远",
    "englishText": "forever, always",
    "explanation": "永 + 远 = eternal + far"
}
```

and it would feed into this template:

```pwsh
$listening_card = @{
    "front" = "[sound:${pinyin}.mp3]"
    "back"  = "${chineseText} (${pinyin})<br><br>${englishText}$<br><br>${explanation}"
    "audioFile" = "${pinyin}$.mp3"
    "chineseText" = "${chineseText}"
    "translation" = "${englishText}$"
} 
```

then, right now, we have reading cards, like this:
```json
{
    "front": "风",
    "back": "[sound:feng1.mp3]<br><br>(fēng)<br><br>wind<br><br><i>Natural force that moves and changes</i>",
    "tags": ["nature", "weather"],
    "audioFile": "feng1.mp3",
    "chineseText": "风",
    "englishText": "wind"
},
```

this instead would get created by the code:
```pwsh
$chinese$_reading_card = @{
    "front" = "${chineseText}"
    "back": "[sound:${name}$.mp3]<br><br>(${pinyin}$)<br><br>${englishText}$<br><br>${explanation}",
    "audioFile": "${name}$.mp3",
    "chineseText": "风",
    "translation": "${englishText}$"
}
```

I also want an $english_reading_card where it has the word in English and you have translate it to Chinese which is on the back.


it doesn't also have the stuff for compound words where it explains waht the characters are made up of

# TESTS

Unit tests:
- Check each card entry and make sure it is actually contained in the lyrics