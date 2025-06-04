# Function to make API requests to An# Function to generate TTS audio for Chinese text
function Add-ChineseTTS {
    param(
        [string]$ChineseText,
        [string]$FileName
    )
    
    # Using Google TTS API (you can also use Azure, AWS Polly, or other services)
    $ttsText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
    $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$ttsText"
    
    Write-Host "TTS URL for '$ChineseText': $ttsUrl"
    return "[sound:$FileName]"
}

# Function to generate audio files if they don't exist
function Initialize-AudioFiles {
    param(
        [string]$AudioDir,
        [array]$RequiredAudioFiles
    )
    
    # Create audio directory if it doesn't exist
    if (-not (Test-Path $AudioDir)) {
        New-Item -ItemType Directory -Path $AudioDir -Force | Out-Null
        Write-Host "Created audio directory: $AudioDir"
    }
    
    $missingFiles = @()
    foreach ($audioFile in $RequiredAudioFiles) {
        $filePath = Join-Path $AudioDir $audioFile.filename
        if (-not (Test-Path $filePath)) {
            $missingFiles += $audioFile
        }
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Host "Missing $($missingFiles.Count) audio files. Generating them now..."
        
        foreach ($audioFile in $missingFiles) {
            $outputPath = Join-Path $AudioDir $audioFile.filename
            
            try {
                $encodedText = [System.Web.HttpUtility]::UrlEncode($audioFile.text)
                $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$encodedText"
                
                Write-Host "Generating TTS for: $($audioFile.text)"
                Invoke-WebRequest -Uri $ttsUrl -OutFile $outputPath -UserAgent "Mozilla/5.0"
                Write-Host "✓ Generated: $($audioFile.filename)"
                
                # Small delay to be respectful to the TTS service
                Start-Sleep -Milliseconds 500
            }
            catch {
                Write-Warning "Failed to generate TTS for '$($audioFile.text)': $_"
            }
        }
    } else {
        Write-Host "All audio files already exist."
    }
}

# Required audio files for all levels
$requiredAudioFiles = @(
    # Level 1: Individual Characters & Basic Words
    @{ text = "忽"; filename = "hu1.mp3" },
    @{ text = "近"; filename = "jin4.mp3" },
    @{ text = "远"; filename = "yuan3.mp3" },
    @{ text = "隐"; filename = "yin3.mp3" },
    @{ text = "现"; filename = "xian4.mp3" },
    @{ text = "明"; filename = "ming2.mp3" },
    @{ text = "暗"; filename = "an4.mp3" },
    @{ text = "快"; filename = "kuai4.mp3" },
    @{ text = "慢"; filename = "man4.mp3" },
    @{ text = "她"; filename = "ta1.mp3" },
    @{ text = "不"; filename = "bu4.mp3" },
    @{ text = "停"; filename = "ting2.mp3" },
    @{ text = "的"; filename = "de.mp3" },
    @{ text = "旋"; filename = "xuan2.mp3" },
    @{ text = "转"; filename = "zhuan3.mp3" },
    @{ text = "无"; filename = "wu2.mp3" },
    @{ text = "休"; filename = "xiu1.mp3" },
    @{ text = "止"; filename = "zhi3.mp3" },
    @{ text = "节"; filename = "jie2.mp3" },
    @{ text = "拍"; filename = "pai1.mp3" },
    @{ text = "在"; filename = "zai4.mp3" },
    @{ text = "空"; filename = "kong1.mp3" },
    @{ text = "荡"; filename = "dang4.mp3" },
    @{ text = "舞"; filename = "wu3.mp3" },
    @{ text = "台"; filename = "tai2.mp3" },
    
    # Level 2: Compound Words & Phrases
    @{ text = "不停"; filename = "bu_ting.mp3" },
    @{ text = "旋转"; filename = "xuan_zhuan.mp3" },
    @{ text = "无休止"; filename = "wu_xiu_zhi.mp3" },
    @{ text = "节拍"; filename = "jie_pai.mp3" },
    @{ text = "空荡"; filename = "kong_dang.mp3" },
    @{ text = "舞台"; filename = "wu_tai.mp3" },
    @{ text = "透明"; filename = "tou_ming.mp3" },
    @{ text = "熄灭"; filename = "xi_mie.mp3" },
    @{ text = "电动"; filename = "dian_dong.mp3" },
    @{ text = "观众"; filename = "guan_zhong.mp3" },
    @{ text = "出丑"; filename = "chu_chou.mp3" },
    @{ text = "幕布"; filename = "mu_bu.mp3" },
    @{ text = "背后"; filename = "bei_hou.mp3" },
    @{ text = "操纵"; filename = "cao_zong.mp3" },
    @{ text = "地球"; filename = "di_qiu.mp3" },
    
    # Level 3: Grammar Patterns & Sentence Fragments
    @{ text = "忽近忽远"; filename = "hu_jin_hu_yuan.mp3" },
    @{ text = "忽隐忽现"; filename = "hu_yin_hu_xian.mp3" },
    @{ text = "忽明忽暗"; filename = "hu_ming_hu_an.mp3" },
    @{ text = "忽快忽慢"; filename = "hu_kuai_hu_man.mp3" },
    @{ text = "她不停的旋转"; filename = "ta_bu_ting_de_xuan_zhuan.mp3" },
    @{ text = "无休止的节拍"; filename = "wu_xiu_zhi_de_jie_pai.mp3" },
    @{ text = "在空荡的舞台"; filename = "zai_kong_dang_de_wu_tai.mp3" },
    @{ text = "她说她是"; filename = "ta_shuo_ta_shi.mp3" },
    @{ text = "舞台下的观众"; filename = "wu_tai_xia_de_guan_zhong.mp3" },
    @{ text = "在等着你"; filename = "zai_deng_zhe_ni.mp3" },
    @{ text = "而幕布的背后"; filename = "er_mu_bu_de_bei_hou.mp3" },
    @{ text = "还有人在"; filename = "hai_you_ren_zai.mp3" },
    @{ text = "她想说她想问"; filename = "ta_xiang_shuo_ta_xiang_wen.mp3" },
    @{ text = "一直转一直转"; filename = "yi_zhi_zhuan_yi_zhi_zhuan.mp3" },
    @{ text = "是为了谁"; filename = "shi_wei_le_shei.mp3" },
    @{ text = "你不用管"; filename = "ni_bu_yong_guan.mp3" },
    @{ text = "就跟我转"; filename = "jiu_gen_wo_zhuan.mp3" },
    
    # Level 4: Complete Lines
    @{ text = "她不停的旋转无休止的节拍"; filename = "complete_line_1.mp3" },
    @{ text = "她不停的旋转在空荡的舞台"; filename = "complete_line_2.mp3" },
    @{ text = "她说她是透明的"; filename = "complete_line_3.mp3" },
    @{ text = "她说她快熄灭了"; filename = "complete_line_4.mp3" },
    @{ text = "她说她是电动的"; filename = "complete_line_5.mp3" },
    @{ text = "舞台下的观众在等着你出丑"; filename = "complete_line_6.mp3" },
    @{ text = "而幕布的背后还有人在操纵"; filename = "complete_line_7.mp3" },
    @{ text = "地球说你不用管就跟我转"; filename = "complete_line_8.mp3" }
)
function Invoke-AnkiConnect {
    param(
        [string]$Action,
        [hashtable]$Params = @{},
        [int]$Version = 6
    )
    
    $body = @{
        action = $Action
        version = $Version
        params = $Params
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8765" -Method Post -Body $body -ContentType "application/json"
        return $response
    } catch {
        Write-Error "Failed to connect to Anki-Connect: $_"
        return $null
    }
}

# Create the Electronic Girl deck with subdecks for all levels
$mainDeckName = "Chinese Learning - Electronic Girl v3"
$listeningDeckName = "$mainDeckName::Listening"
$readingDeckName = "$mainDeckName::Reading"

# Create level subdecks with integrated approach (combining traditional levels 1 & 2)
$level1ListeningDeck = "$listeningDeckName::Level 1 - Building Blocks (Characters to Phrases)"
$level2ListeningDeck = "$listeningDeckName::Level 2 - Complete Lines"

$level1ReadingDeck = "$readingDeckName::Level 1 - Building Blocks (Characters to Phrases)"
$level2ReadingDeck = "$readingDeckName::Level 2 - Complete Lines"

# Create all decks
$decksToCreate = @(
    $mainDeckName,
    $listeningDeckName,
    $readingDeckName,
    $level1ListeningDeck,
    $level2ListeningDeck,
    $level1ReadingDeck,
    $level2ReadingDeck
)

Write-Host "Creating deck structure..."
foreach ($deckName in $decksToCreate) {
    $response = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $deckName }
    if ($response.error) {
        Write-Warning "Failed to create deck '$deckName': $($response.error)"
    } else {
        Write-Host "✓ Created deck: $deckName"
    }
}

# Function to generate TTS audio for Chinese text
function Add-ChineseTTS {
    param(
        [string]$ChineseText,
        [string]$FileName
    )
    
    # Using Google TTS API (you can also use Azure, AWS Polly, or other services)
    $ttsText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
    $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$ttsText"
    
    Write-Host "TTS URL for '$ChineseText': $ttsUrl"
    return "[sound:$FileName]"
}

# Level 1 Listening Cards: Integrated Building Blocks (Characters to Phrases)
# This level combines what were previously separate character and compound levels
# Building concepts progressively from individual characters to compounds to key phrases
$level1ListeningCards = @(
    # Concept Group 1: The "suddenly" pattern (忽X忽Y)
    # Start with the core pattern character
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu1.mp3]"
            Back = "忽 (hū)<br><br>suddenly, abruptly<br><br><i>Key pattern word in: 忽近忽远, 忽隐忽现...</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adverb", "pattern-word")
    },
    # Build the opposites used in the pattern
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jin4.mp3]"
            Back = "近 (jìn)<br><br>near, close<br><br><i>Opposite of 远. Used in: 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adjective", "spatial")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:yuan3.mp3]"
            Back = "远 (yuǎn)<br><br>far, distant<br><br><i>Opposite of 近. Used in: 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adjective", "spatial")
    },
    # Now the complete pattern phrase
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_jin_hu_yuan.mp3]"
            Back = "忽近忽远 (hū jìn hū yuǎn)<br><br>suddenly near, suddenly far<br><br><i>Pattern: 忽X忽Y = suddenly X, suddenly Y</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "spatial", "key-lyric")
    },
    
    # Concept Group 2: More 忽X忽Y patterns to reinforce the concept
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_yin_hu_xian.mp3]"
            Back = "忽隐忽现 (hū yǐn hū xiàn)<br><br>suddenly gone, suddenly there<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "visibility")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_ming_hu_an.mp3]"
            Back = "忽明忽暗 (hū míng hū àn)<br><br>suddenly bright, suddenly dark<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "lighting")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_kuai_hu_man.mp3]"
            Back = "忽快忽慢 (hū kuài hū màn)<br><br>suddenly fast, suddenly slow<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "speed")
    },

    # Concept Group 3: Continuous action - building 不停
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:bu4.mp3]"
            Back = "不 (bù)<br><br>not, no<br><br><i>Negation word - used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "negation")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ting2.mp3]"
            Back = "停 (tíng)<br><br>stop, halt<br><br><i>Used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:bu_ting.mp3]"
            Back = "不停 (bù tíng)<br><br>non-stop, continuously<br><br><i>不 + 停 = not + stop = non-stop</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "word", "adverb", "continuous")
    },

    # Concept Group 4: The spinning action - building 旋转
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xuan2.mp3]"
            Back = "旋 (xuán)<br><br>revolve, spin<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb", "movement")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zhuan3.mp3]"
            Back = "转 (zhuǎn)<br><br>turn, rotate<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb", "movement")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xuan_zhuan.mp3]"
            Back = "旋转 (xuán zhuǎn)<br><br>spin, rotate<br><br><i>旋 + 转 = both mean turning/spinning</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "word", "verb", "movement")
    },

    # Concept Group 5: Building the key phrase 她不停的旋转
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta1.mp3]"
            Back = "她 (tā)<br><br>she, her<br><br><i>Subject of: 她不停的旋转 (she keeps spinning)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "pronoun")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:de.mp3]"
            Back = "的 (de)<br><br>possessive/descriptive particle<br><br><i>Links words: 她不停的旋转 (she continuously spins)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "particle")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_bu_ting_de_xuan_zhuan.mp3]"
            Back = "她不停的旋转 (tā bù tíng de xuán zhuǎn)<br><br>She keeps on spinning<br><br><i>Putting it all together: 她 + 不停 + 的 + 旋转</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "key-lyric", "complete-thought")
    },

    # Concept Group 6: Stage and rhythm concepts
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_xiu_zhi_de_jie_pai.mp3]"
            Back = "无休止的节拍 (wú xiū zhǐ de jié pāi)<br><br>endless rhythm/beat<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "rhythm", "key-lyric")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zai_kong_dang_de_wu_tai.mp3]"
            Back = "在空荡的舞台 (zài kōng dàng de wǔ tái)<br><br>on the empty stage<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "stage", "key-lyric")
    }
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jin4.mp3]"
            Back = "近 (jìn)<br><br>near, close<br><br><i>Used in: 忽近忽远 (suddenly near and far)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adjective")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:yuan3.mp3]"
            Back = "远 (yuǎn)<br><br>far, distant<br><br><i>Used in: 忽近忽远 (suddenly near and far)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adjective")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_jin_hu_yuan.mp3]"
            Back = "忽近忽远 (hū jìn hū yuǎn)<br><br>suddenly near, suddenly far<br><br><i>Pattern: 忽X忽Y = suddenly X, suddenly Y</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "lyric-line")
    },
    
    # Building on the pattern with more examples
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:yin3.mp3]"
            Back = "隐 (yǐn)<br><br>hidden, concealed<br><br><i>Used in: 忽隐忽现 (suddenly appearing and disappearing)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adjective")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xian4.mp3]"
            Back = "现 (xiàn)<br><br>appear, show up<br><br><i>Used in: 忽隐忽现 (suddenly appearing and disappearing)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_yin_hu_xian.mp3]"
            Back = "忽隐忽现 (hū yǐn hū xiàn)<br><br>suddenly gone, suddenly there<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "pattern", "lyric-line")
    },
    
    # Core concept: continuous action - 不停
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:bu4.mp3]"
            Back = "不 (bù)<br><br>not, no<br><br><i>Negation word - used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "negation")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ting2.mp3]"
            Back = "停 (tíng)<br><br>stop, halt<br><br><i>Used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:bu_ting.mp3]"
            Back = "不停 (bù tíng)<br><br>non-stop, continuously<br><br><i>不 + 停 = not + stop = non-stop</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "word", "adverb")
    },
    
    # Core concept: spinning - 旋转
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xuan2.mp3]"
            Back = "旋 (xuán)<br><br>revolve, spin<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zhuan3.mp3]"
            Back = "转 (zhuǎn)<br><br>turn, rotate<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "verb")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xuan_zhuan.mp3]"
            Back = "旋转 (xuán zhuǎn)<br><br>spin, rotate<br><br><i>旋 + 转 = both mean turning/spinning</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "word", "verb")
    },
    
    # Building the key phrase: 她不停的旋转
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta1.mp3]"
            Back = "她 (tā)<br><br>she, her<br><br><i>Subject of: 她不停的旋转 (she keeps spinning)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "pronoun")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:de.mp3]"
            Back = "的 (de)<br><br>possessive/descriptive particle<br><br><i>Links words: 她不停的旋转 (she continuously spins)</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "particle")
    },
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_bu_ting_de_xuan_zhuan.mp3]"
            Back = "她不停的旋转 (tā bù tíng de xuán zhuǎn)<br><br>She keeps on spinning<br><br><i>Putting it all together: 她 + 不停 + 的 + 旋转</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "key-lyric")
    }
)

# Level 1 Reading Cards: Integrated Building Blocks (Characters to Phrases)
# Mirror structure of listening cards but with Chinese text on front, audio + meaning on back
$level1ReadingCards = @(
    # Concept Group 1: The "suddenly" pattern (忽X忽Y)
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽"
            Back = "[sound:hu1.mp3]<br><br>(hū) suddenly, abruptly<br><br><i>Key pattern word in: 忽近忽远, 忽隐忽现...</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "adverb", "pattern-word")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "近"
            Back = "[sound:jin4.mp3]<br><br>(jìn) near, close<br><br><i>Opposite of 远. Used in: 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "adjective", "spatial")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "远"
            Back = "[sound:yuan3.mp3]<br><br>(yuǎn) far, distant<br><br><i>Opposite of 近. Used in: 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "adjective", "spatial")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽近忽远"
            Back = "[sound:hu_jin_hu_yuan.mp3]<br><br>(hū jìn hū yuǎn) suddenly near, suddenly far<br><br><i>Pattern: 忽X忽Y = suddenly X, suddenly Y</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "pattern", "spatial", "key-lyric")
    },
    
    # Concept Group 2: More 忽X忽Y patterns to reinforce the concept
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽隐忽现"
            Back = "[sound:hu_yin_hu_xian.mp3]<br><br>(hū yǐn hū xiàn) suddenly gone, suddenly there<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "pattern", "visibility")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽明忽暗"
            Back = "[sound:hu_ming_hu_an.mp3]<br><br>(hū míng hū àn) suddenly bright, suddenly dark<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "pattern", "lighting")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽快忽慢"
            Back = "[sound:hu_kuai_hu_man.mp3]<br><br>(hū kuài hū màn) suddenly fast, suddenly slow<br><br><i>Same pattern as 忽近忽远</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "pattern", "speed")
    },

    # Concept Group 3: Continuous action - building 不停
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "不"
            Back = "[sound:bu4.mp3]<br><br>(bù) not, no<br><br><i>Negation word - used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "negation")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "停"
            Back = "[sound:ting2.mp3]<br><br>(tíng) stop, halt<br><br><i>Used in 不停 (non-stop)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "verb")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "不停"
            Back = "[sound:bu_ting.mp3]<br><br>(bù tíng) non-stop, continuously<br><br><i>不 + 停 = not + stop = non-stop</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "word", "adverb", "continuous")
    },

    # Concept Group 4: The spinning action - building 旋转
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "旋"
            Back = "[sound:xuan2.mp3]<br><br>(xuán) revolve, spin<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "verb", "movement")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "转"
            Back = "[sound:zhuan3.mp3]<br><br>(zhuǎn) turn, rotate<br><br><i>Used in 旋转 (spinning, rotating)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "verb", "movement")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "旋转"
            Back = "[sound:xuan_zhuan.mp3]<br><br>(xuán zhuǎn) spin, rotate<br><br><i>旋 + 转 = both mean turning/spinning</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "word", "verb", "movement")
    },

    # Concept Group 5: Building the key phrase 她不停的旋转
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她"
            Back = "[sound:ta1.mp3]<br><br>(tā) she, her<br><br><i>Subject of: 她不停的旋转 (she keeps spinning)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "pronoun")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "的"
            Back = "[sound:de.mp3]<br><br>(de) possessive/descriptive particle<br><br><i>Links words: 她不停的旋转 (she continuously spins)</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "character", "particle")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她不停的旋转"
            Back = "[sound:ta_bu_ting_de_xuan_zhuan.mp3]<br><br>(tā bù tíng de xuán zhuǎn) She keeps on spinning<br><br><i>Putting it all together: 她 + 不停 + 的 + 旋转</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "key-lyric", "complete-thought")
    },

    # Concept Group 6: Stage and rhythm concepts  
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无休止的节拍"
            Back = "[sound:wu_xiu_zhi_de_jie_pai.mp3]<br><br>(wú xiū zhǐ de jié pāi) endless rhythm/beat<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "rhythm", "key-lyric")
    },
    @{
        deckName = $level1ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "在空荡的舞台"
            Back = "[sound:zai_kong_dang_de_wu_tai.mp3]<br><br>(zài kōng dàng de wǔ tái) on the empty stage<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "stage", "key-lyric")
    }
)

Write-Host "Adding Level 1 example cards with TTS audio..."

# Define paths for audio handling
$ankiMediaDir = "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"
$localAudioDir = Join-Path $PSScriptRoot "audio"

# Function to copy audio files to Anki media directory
function Copy-AudioToAnki {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )
    
    if (-not (Test-Path $SourceDir)) {
        Write-Warning "Local audio directory not found at: $SourceDir"
        Write-Host "Run GenerateAudioFiles.ps1 first to create the audio files."
        return $false
    }
    
    if (-not (Test-Path $DestinationDir)) {
        Write-Warning "Anki media directory not found at: $DestinationDir"
        Write-Host "Please make sure Anki is installed and has been run at least once."
        return $false
    }
    
    Write-Host "Copying audio files from $SourceDir to Anki media directory..."
    
    $audioFiles = Get-ChildItem -Path $SourceDir -Filter "*.mp3"
    $copiedCount = 0
    
    foreach ($file in $audioFiles) {
        $destPath = Join-Path $DestinationDir $file.Name
        
        try {
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            Write-Host "✓ Copied: $($file.Name)"
            $copiedCount++
        }
        catch {
            Write-Warning "Failed to copy $($file.Name): $_"
        }
    }
    
    Write-Host "Successfully copied $copiedCount audio files to Anki media directory."
    return $true
}

# Copy audio files to Anki media directory
$audioCopySuccess = Copy-AudioToAnki -SourceDir $localAudioDir -DestinationDir $ankiMediaDir

# Ensure all required audio files exist before copying
Write-Host "Checking for required audio files..."
Initialize-AudioFiles -AudioDir $localAudioDir -RequiredAudioFiles $requiredAudioFiles

# Copy audio files to Anki media directory
$audioCopySuccess = Copy-AudioToAnki -SourceDir $localAudioDir -DestinationDir $ankiMediaDir

if (-not $audioCopySuccess) {
    Write-Host "Note: Audio files will need to be manually placed in Anki's media folder."
    Write-Host "Local audio files are available in: $localAudioDir"
}

# Add listening cards
Write-Host "`nAdding listening cards (Audio → Character + Meaning)..."
foreach ($card in $level1ListeningCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add listening card '$($card.fields.Front)': $($response.error)"
    } else {
        Write-Host "✓ Added listening card - ID: $($response.result)"
    }
}

# Add reading cards
Write-Host "`nAdding reading cards (Character → Audio + Meaning)..."
foreach ($card in $level1ReadingCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add reading card '$($card.fields.Front)': $($response.error)"
    } else {
        Write-Host "✓ Added reading card: $($card.fields.Front) - ID: $($response.result)"
    }
}

Write-Host "`nElectronic Girl deck creation complete!"
Write-Host "Created $($level1ListeningCards.Count) listening cards and $($level1ReadingCards.Count) reading cards."

# Get deck statistics for both subdecks
$listeningStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($listeningDeckName)
}

$readingStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($readingDeckName)
}

if ($listeningStatsResponse.result) {
    $listeningStats = $listeningStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "`nListening deck stats - Total cards: $($listeningStats.total_in_deck), New: $($listeningStats.new_count)"
}

if ($readingStatsResponse.result) {
    $readingStats = $readingStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "Reading deck stats - Total cards: $($readingStats.total_in_deck), New: $($readingStats.new_count)"
}

# Level 2 Listening Cards: Complete Lyric Lines
# After mastering the building blocks in Level 1, students practice complete song lines
$level2ListeningCards = @(
    # Key lyric lines from the song
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_bu_ting_de_xuan_zhuan_wu_xiu_zhi_de_jie_pai.mp3]"
            Back = "她不停的旋转无休止的节拍<br><br>(tā bù tíng de xuán zhuǎn wú xiū zhǐ de jié pāi)<br><br>She keeps on spinning to the endless beat<br><br><i>Complete lyric line combining key concepts from Level 1</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "complete-line", "main-theme")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_bu_ting_de_xuan_zhuan_zai_kong_dang_de_wu_tai.mp3]"
            Back = "她不停的旋转在空荡的舞台<br><br>(tā bù tíng de xuán zhuǎn zài kōng dàng de wǔ tái)<br><br>She keeps on spinning on the empty stage<br><br><i>Complete lyric line about the stage setting</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "complete-line", "stage-setting")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_shuo_ta_shi_tou_ming_de.mp3]"
            Back = "她说她是透明的<br><br>(tā shuō tā shì tòu míng de)<br><br>She says she is transparent<br><br><i>Character description from the song</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "complete-line", "character-trait")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_shuo_ta_kuai_xi_mie_le.mp3]"
            Back = "她说她快熄灭了<br><br>(tā shuō tā kuài xī miè le)<br><br>She says she's about to burn out<br><br><i>Emotional expression from the song</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "complete-line", "emotion")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ta_shuo_ta_shi_dian_dong_de.mp3]"
            Back = "她说她是电动的<br><br>(tā shuō tā shì diàn dòng de)<br><br>She says she is electronic/electric<br><br><i>Title concept - electronic girl</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "complete-line", "electronic-theme")
    }
)

# Level 2 Reading Cards: Complete Lyric Lines
# Mirror structure of listening cards but with Chinese text on front
$level2ReadingCards = @(
    # Key lyric lines from the song
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她不停的旋转无休止的节拍"
            Back = "[sound:ta_bu_ting_de_xuan_zhuan_wu_xiu_zhi_de_jie_pai.mp3]<br><br>(tā bù tíng de xuán zhuǎn wú xiū zhǐ de jié pāi)<br><br>She keeps on spinning to the endless beat<br><br><i>Complete lyric line combining key concepts from Level 1</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "complete-line", "main-theme")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她不停的旋转在空荡的舞台"
            Back = "[sound:ta_bu_ting_de_xuan_zhuan_zai_kong_dang_de_wu_tai.mp3]<br><br>(tā bù tíng de xuán zhuǎn zài kōng dàng de wǔ tái)<br><br>She keeps on spinning on the empty stage<br><br><i>Complete lyric line about the stage setting</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "complete-line", "stage-setting")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她说她是透明的"
            Back = "[sound:ta_shuo_ta_shi_tou_ming_de.mp3]<br><br>(tā shuō tā shì tòu míng de)<br><br>She says she is transparent<br><br><i>Character description from the song</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "complete-line", "character-trait")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她说她快熄灭了"
            Back = "[sound:ta_shuo_ta_kuai_xi_mie_le.mp3]<br><br>(tā shuō tā kuài xī miè le)<br><br>She says she's about to burn out<br><br><i>Emotional expression from the song</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "complete-line", "emotion")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "她说她是电动的"
            Back = "[sound:ta_shuo_ta_shi_dian_dong_de.mp3]<br><br>(tā shuō tā shì diàn dòng de)<br><br>She says she is electronic/electric<br><br><i>Title concept - electronic girl</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "complete-line", "electronic-theme")
    }
)

Write-Host "Adding Level 2 example cards with TTS audio..."

# Add Level 2 listening cards
Write-Host "`nAdding Level 2 listening cards (Audio → Complete Lines + Meaning)..."
foreach ($card in $level2ListeningCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add Level 2 listening card '$($card.fields.Front)': $($response.error)"
    } else {
        Write-Host "✓ Added Level 2 listening card - ID: $($response.result)"
    }
}

# Add Level 2 reading cards
Write-Host "`nAdding Level 2 reading cards (Complete Lines → Audio + Meaning)..."
foreach ($card in $level2ReadingCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add Level 2 reading card '$($card.fields.Front)': $($response.error)"
    } else {
        Write-Host "✓ Added Level 2 reading card: $($card.fields.Front) - ID: $($response.result)"
    }
}

Write-Host "`nElectronic Girl v3 deck creation complete!"
Write-Host "Created $($level1ListeningCards.Count) Level 1 listening cards and $($level1ReadingCards.Count) Level 1 reading cards."
Write-Host "Created $($level2ListeningCards.Count) Level 2 listening cards and $($level2ReadingCards.Count) Level 2 reading cards."

# Get deck statistics for all subdecks
$level1ListeningStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($level1ListeningDeck)
}

$level1ReadingStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($level1ReadingDeck)
}

$level2ListeningStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($level2ListeningDeck)
}

$level2ReadingStatsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($level2ReadingDeck)
}

if ($level1ListeningStatsResponse.result) {
    $level1ListeningStats = $level1ListeningStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "`nLevel 1 Listening deck stats - Total cards: $($level1ListeningStats.total_in_deck), New: $($level1ListeningStats.new_count)"
}

if ($level1ReadingStatsResponse.result) {
    $level1ReadingStats = $level1ReadingStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "Level 1 Reading deck stats - Total cards: $($level1ReadingStats.total_in_deck), New: $($level1ReadingStats.new_count)"
}

if ($level2ListeningStatsResponse.result) {
    $level2ListeningStats = $level2ListeningStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "Level 2 Listening deck stats - Total cards: $($level2ListeningStats.total_in_deck), New: $($level2ListeningStats.new_count)"
}

if ($level2ReadingStatsResponse.result) {
    $level2ReadingStats = $level2ReadingStatsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "Level 2 Reading deck stats - Total cards: $($level2ReadingStats.total_in_deck), New: $($level2ReadingStats.new_count)"
}

Write-Host "`nDeck structure:"
Write-Host "📚 Chinese Learning - Electronic Girl v3"
Write-Host "  🎧 Level 1 - Building Blocks (Listening)"
Write-Host "  📖 Level 1 - Building Blocks (Reading)"  
Write-Host "  🎧 Level 2 - Complete Lines (Listening)"
Write-Host "  📖 Level 2 - Complete Lines (Reading)"
Write-Host "`nReady to start learning! Begin with Level 1 Building Blocks."
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:dang4.mp3]"
            Back = "荡 (dàng)<br><br>sway, empty<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:kong_dang.mp3]"
            Back = "空荡 (kōng dàng)<br><br>empty, desolate<br><br><i>空 (empty) + 荡 (hollow) = completely empty</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zai4.mp3]"
            Back = "在 (zài)<br><br>at, in, on<br><br><i>Preposition: 在空荡的舞台 (on the empty stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "preposition")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zai_kong_dang_de_wu_tai.mp3]"
            Back = "在空荡的舞台 (zài kōng dàng de wǔ tái)<br><br>on an empty stage<br><br><i>在 + 空荡的 + 舞台 = on + empty + stage</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "key-lyric")
    },
    
    # Beat and rhythm concepts
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu2.mp3]"
            Back = "无 (wú)<br><br>without, no<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "negation")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xiu1.mp3]"
            Back = "休 (xiū)<br><br>rest, stop<br><br><i>Used in: 无休止 (without rest, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "verb")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zhi3.mp3]"
            Back = "止 (zhǐ)<br><br>stop, end<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "verb")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_xiu_zhi.mp3]"
            Back = "无休止 (wú xiū zhǐ)<br><br>endless, without rest<br><br><i>无 (without) + 休止 (rest/stop) = endless</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jie2.mp3]"
            Back = "节 (jié)<br><br>beat, rhythm, section<br><br><i>Used in: 节拍 (beat, rhythm)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:pai1.mp3]"
            Back = "拍 (pāi)<br><br>beat, clap<br><br><i>Used in: 节拍 (rhythm, beat)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jie_pai.mp3]"
            Back = "节拍 (jié pāi)<br><br>beat, rhythm<br><br><i>节 (rhythm) + 拍 (beat) = musical beat</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_xiu_zhi_de_jie_pai.mp3]"
            Back = "无休止的节拍 (wú xiū zhǐ de jié pāi)<br><br>a neverending beat<br><br><i>Combining: 无休止的 + 节拍 = endless + beat</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "key-lyric")
    }
)

# Level 2 Reading Cards: Grammar Patterns & Stage Concepts
$level2ReadingCards = @(
    # Expanding the 忽X忽Y pattern with more examples
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "明"
            Back = "[sound:ming2.mp3]<br><br>(míng) bright, clear<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "暗"
            Back = "[sound:an4.mp3]<br><br>(àn) dark, dim<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽明忽暗"
            Back = "[sound:hu_ming_hu_an.mp3]<br><br>(hū míng hū àn) suddenly bright, suddenly dark<br><br><i>Another example of the 忽X忽Y pattern</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "pattern", "lyric-line")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "快"
            Back = "[sound:kuai4.mp3]<br><br>(kuài) fast, quick<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "慢"
            Back = "[sound:man4.mp3]<br><br>(màn) slow<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽快忽慢"
            Back = "[sound:hu_kuai_hu_man.mp3]<br><br>(hū kuài hū màn) suddenly fast, suddenly slow<br><br><i>Completing the four 忽X忽Y patterns</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "pattern", "lyric-line")
    },
    
    # Building stage/theater vocabulary
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "舞"
            Back = "[sound:wu3.mp3]<br><br>(wǔ) dance<br><br><i>Used in: 舞台 (stage, dance platform)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "台"
            Back = "[sound:tai2.mp3]<br><br>(tái) platform, stage<br><br><i>Used in: 舞台 (dance stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "舞台"
            Back = "[sound:wu_tai.mp3]<br><br>(wǔ tái) stage<br><br><i>舞 (dance) + 台 (platform) = dance stage</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "空"
            Back = "[sound:kong1.mp3]<br><br>(kōng) empty, hollow<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "荡"
            Back = "[sound:dang4.mp3]<br><br>(dàng) sway, empty<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "空荡"
            Back = "[sound:kong_dang.mp3]<br><br>(kōng dàng) empty, desolate<br><br><i>空 (empty) + 荡 (hollow) = completely empty</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "在"
            Back = "[sound:zai4.mp3]<br><br>(zài) at, in, on<br><br><i>Preposition: 在空荡的舞台 (on the empty stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "preposition")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "在空荡的舞台"
            Back = "[sound:zai_kong_dang_de_wu_tai.mp3]<br><br>(zài kōng dàng de wǔ tái) on an empty stage<br><br><i>在 + 空荡的 + 舞台 = on + empty + stage</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "key-lyric")
    },
    
    # Beat and rhythm concepts
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无"
            Back = "[sound:wu2.mp3]<br><br>(wú) without, no<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "negation")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "休"
            Back = "[sound:xiu1.mp3]<br><br>(xiū) rest, stop<br><br><i>Used in: 无休止 (without rest, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "verb")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "止"
            Back = "[sound:zhi3.mp3]<br><br>(zhǐ) stop, end<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "verb")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无休止"
            Back = "[sound:wu_xiu_zhi.mp3]<br><br>(wú xiū zhǐ) endless, without rest<br><br><i>无 (without) + 休止 (rest/stop) = endless</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "节"
            Back = "[sound:jie2.mp3]<br><br>(jié) beat, rhythm, section<br><br><i>Used in: 节拍 (beat, rhythm)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "拍"
            Back = "[sound:pai1.mp3]<br><br>(pāi) beat, clap<br><br><i>Used in: 节拍 (rhythm, beat)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "节拍"
            Back = "[sound:jie_pai.mp3]<br><br>(jié pāi) beat, rhythm<br><br><i>节 (rhythm) + 拍 (beat) = musical beat</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无休止的节拍"
            Back = "[sound:wu_xiu_zhi_de_jie_pai.mp3]<br><br>(wú xiū zhǐ de jié pāi) a neverending beat<br><br><i>Combining: 无休止的 + 节拍 = endless + beat</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "key-lyric")
    }
)

Write-Host "Adding Level 2 example cards with TTS audio..."

# Level 2 Listening Cards: Audio → Characters + Meaning (Integrated Learning)
$level2ListeningCards = @(
    # Expanding the 忽X忽Y pattern with more examples
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:ming2.mp3]"
            Back = "明 (míng)<br><br>bright, clear<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:an4.mp3]"
            Back = "暗 (àn)<br><br>dark, dim<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_ming_hu_an.mp3]"
            Back = "忽明忽暗 (hū míng hū àn)<br><br>suddenly bright, suddenly dark<br><br><i>Another example of the 忽X忽Y pattern</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "pattern", "lyric-line")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:kuai4.mp3]"
            Back = "快 (kuài)<br><br>fast, quick<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:man4.mp3]"
            Back = "慢 (màn)<br><br>slow<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu_kuai_hu_man.mp3]"
            Back = "忽快忽慢 (hū kuài hū màn)<br><br>suddenly fast, suddenly slow<br><br><i>Completing the four 忽X忽Y patterns</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "pattern", "lyric-line")
    },
    
    # Building stage/theater vocabulary
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu3.mp3]"
            Back = "舞 (wǔ)<br><br>dance<br><br><i>Used in: 舞台 (stage, dance platform)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:tai2.mp3]"
            Back = "台 (tái)<br><br>platform, stage<br><br><i>Used in: 舞台 (dance stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_tai.mp3]"
            Back = "舞台 (wǔ tái)<br><br>stage<br><br><i>舞 (dance) + 台 (platform) = dance stage</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:kong1.mp3]"
            Back = "空 (kōng)<br><br>empty, hollow<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:dang4.mp3]"
            Back = "荡 (dàng)<br><br>sway, empty<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:kong_dang.mp3]"
            Back = "空荡 (kōng dàng)<br><br>empty, desolate<br><br><i>空 (empty) + 荡 (hollow) = completely empty</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zai4.mp3]"
            Back = "在 (zài)<br><br>at, in, on<br><br><i>Preposition: 在空荡的舞台 (on the empty stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "preposition")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zai_kong_dang_de_wu_tai.mp3]"
            Back = "在空荡的舞台 (zài kōng dàng de wǔ tái)<br><br>on an empty stage<br><br><i>在 + 空荡的 + 舞台 = on + empty + stage</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "key-lyric")
    },
    
    # Beat and rhythm concepts
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu2.mp3]"
            Back = "无 (wú)<br><br>without, no<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "negation")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:xiu1.mp3]"
            Back = "休 (xiū)<br><br>rest, stop<br><br><i>Used in: 无休止 (without rest, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "verb")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:zhi3.mp3]"
            Back = "止 (zhǐ)<br><br>stop, end<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "verb")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_xiu_zhi.mp3]"
            Back = "无休止 (wú xiū zhǐ)<br><br>endless, without rest<br><br><i>无 (without) + 休止 (rest/stop) = endless</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "adjective")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jie2.mp3]"
            Back = "节 (jié)<br><br>beat, rhythm, section<br><br><i>Used in: 节拍 (beat, rhythm)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:pai1.mp3]"
            Back = "拍 (pāi)<br><br>beat, clap<br><br><i>Used in: 节拍 (rhythm, beat)</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "character", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:jie_pai.mp3]"
            Back = "节拍 (jié pāi)<br><br>beat, rhythm<br><br><i>节 (rhythm) + 拍 (beat) = musical beat</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "word", "noun")
    },
    @{
        deckName = $level2ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:wu_xiu_zhi_de_jie_pai.mp3]"
            Back = "无休止的节拍 (wú xiū zhǐ de jié pāi)<br><br>a neverending beat<br><br><i>Combining: 无休止的 + 节拍 = endless + beat</i>"
        }
        tags = @("electronic-girl", "level-2", "listening", "phrase", "key-lyric")
    }
)

# Level 2 Reading Cards: Characters → Audio + Meaning (Integrated Learning)
$level2ReadingCards = @(
    # Expanding the 忽X忽Y pattern with more examples
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "明"
            Back = "[sound:ming2.mp3]<br><br>(míng) bright, clear<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "暗"
            Back = "[sound:an4.mp3]<br><br>(àn) dark, dim<br><br><i>Used in: 忽明忽暗 (suddenly bright, suddenly dark)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽明忽暗"
            Back = "[sound:hu_ming_hu_an.mp3]<br><br>(hū míng hū àn) suddenly bright, suddenly dark<br><br><i>Another example of the 忽X忽Y pattern</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "pattern", "lyric-line")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "快"
            Back = "[sound:kuai4.mp3]<br><br>(kuài) fast, quick<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "慢"
            Back = "[sound:man4.mp3]<br><br>(màn) slow<br><br><i>Used in: 忽快忽慢 (suddenly fast, suddenly slow)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "忽快忽慢"
            Back = "[sound:hu_kuai_hu_man.mp3]<br><br>(hū kuài hū màn) suddenly fast, suddenly slow<br><br><i>Completing the four 忽X忽Y patterns</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "pattern", "lyric-line")
    },
    
    # Building stage/theater vocabulary
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "舞"
            Back = "[sound:wu3.mp3]<br><br>(wǔ) dance<br><br><i>Used in: 舞台 (stage, dance platform)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "台"
            Back = "[sound:tai2.mp3]<br><br>(tái) platform, stage<br><br><i>Used in: 舞台 (dance stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "舞台"
            Back = "[sound:wu_tai.mp3]<br><br>(wǔ tái) stage<br><br><i>舞 (dance) + 台 (platform) = dance stage</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "noun")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "空"
            Back = "[sound:kong1.mp3]<br><br>(kōng) empty, hollow<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "荡"
            Back = "[sound:dang4.mp3]<br><br>(dàng) sway, empty<br><br><i>Used in: 空荡 (empty and desolate)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "空荡"
            Back = "[sound:kong_dang.mp3]<br><br>(kōng dàng) empty, desolate<br><br><i>空 (empty) + 荡 (hollow) = completely empty</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "在"
            Back = "[sound:zai4.mp3]<br><br>(zài) at, in, on<br><br><i>Preposition: 在空荡的舞台 (on the empty stage)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "preposition")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "在空荡的舞台"
            Back = "[sound:zai_kong_dang_de_wu_tai.mp3]<br><br>(zài kōng dàng de wǔ tái) on an empty stage<br><br><i>在 + 空荡的 + 舞台 = on + empty + stage</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "phrase", "key-lyric")
    },
    
    # Beat and rhythm concepts
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无"
            Back = "[sound:wu2.mp3]<br><br>(wú) without, no<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "negation")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "休"
            Back = "[sound:xiu1.mp3]<br><br>(xiū) rest, stop<br><br><i>Used in: 无休止 (without rest, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "verb")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "止"
            Back = "[sound:zhi3.mp3]<br><br>(zhǐ) stop, end<br><br><i>Used in: 无休止 (without end, endless)</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "character", "verb")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "无休止"
            Back = "[sound:wu_xiu_zhi.mp3]<br><br>(wú xiū zhǐ) endless, without rest<br><br><i>无 (without) + 休止 (rest/stop) = endless</i>"
        }
        tags = @("electronic-girl", "level-2", "reading", "word", "adjective")
    },
    @{
        deckName = $level2ReadingDeck
        modelName = "Basic"
        fields = @{
            Front = "节"
            Back = "[sound:jie2.mp3]<br><br>(jié) beat, rhythm, section<br><br><i>Used in: 节拍 (beat, rhythm)</i>"
        }
        tags = @