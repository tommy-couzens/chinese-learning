# Electronic Girl Deck Creation Script - Version 3 (Clean)
# Creates an Anki deck using anki-connect to help learn Chinese Football's "Electronic Girl"
# Organized into 2 levels with integrated learning approach

# Check if Anki Connect is available
function Test-AnkiConnect {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8765" -Method Post -Body '{"action": "version", "version": 6}' -ContentType "application/json"
        return $response.result -ne $null
    }
    catch {
        return $false
    }
}

function Invoke-AnkiConnect {
    param(
        [string]$Action,
        [hashtable]$Params = @{}
    )
    
    $requestBody = @{
        action = $Action
        version = 6
        params = $Params
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8765" -Method Post -Body $requestBody -ContentType "application/json"
        return $response
    }
    catch {
        Write-Error "Failed to connect to Anki: $_"
        return @{ error = $_.Exception.Message }
    }
}

# Test Anki Connect
if (-not (Test-AnkiConnect)) {
    Write-Error "Anki Connect is not available. Please:"
    Write-Host "1. Make sure Anki is running"
    Write-Host "2. Install the AnkiConnect add-on (code: 2055492159)"
    Write-Host "3. Restart Anki"
    exit 1
}

Write-Host "✓ Connected to Anki via AnkiConnect"

# Deck configuration
$mainDeckName = "Chinese Learning - Electronic Girl v3"
$level1ListeningDeck = "$mainDeckName::Level 1 - Building Blocks (Listening)"
$level1ReadingDeck = "$mainDeckName::Level 1 - Building Blocks (Reading)"
$level2ListeningDeck = "$mainDeckName::Level 2 - Complete Lines (Listening)"
$level2ReadingDeck = "$mainDeckName::Level 2 - Complete Lines (Reading)"

# Create main deck and subdecks
Write-Host "Creating deck structure..."
$mainDeckResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $mainDeckName }
$level1ListeningResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $level1ListeningDeck }
$level1ReadingResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $level1ReadingDeck }
$level2ListeningResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $level2ListeningDeck }
$level2ReadingResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $level2ReadingDeck }

Write-Host "✓ Created deck structure"

# Required audio files - these should already exist in the audio directory
$requiredAudioFiles = @(
    "hu1.mp3", "jin4.mp3", "yuan3.mp3", "hu_jin_hu_yuan.mp3",
    "hu_yin_hu_xian.mp3", "hu_ming_hu_an.mp3", "hu_kuai_hu_man.mp3",
    "bu4.mp3", "ting2.mp3", "bu_ting.mp3",
    "xuan2.mp3", "zhuan3.mp3", "xuan_zhuan.mp3",
    "ta1.mp3", "de.mp3", "ta_bu_ting_de_xuan_zhuan.mp3",
    "wu_xiu_zhi_de_jie_pai.mp3", "zai_kong_dang_de_wu_tai.mp3",
    "ta_bu_ting_de_xuan_zhuan_wu_xiu_zhi_de_jie_pai.mp3",
    "ta_bu_ting_de_xuan_zhuan_zai_kong_dang_de_wu_tai.mp3",
    "ta_shuo_ta_shi_tou_ming_de.mp3",
    "ta_shuo_ta_kuai_xi_mie_le.mp3",
    "ta_shuo_ta_shi_dian_dong_de.mp3"
)

# Level 1 Listening Cards: Integrated Building Blocks (Characters to Phrases)
$level1ListeningCards = @(
    # Concept Group 1: The "suddenly" pattern (忽X忽Y)
    @{
        deckName = $level1ListeningDeck
        modelName = "Basic"
        fields = @{
            Front = "[sound:hu1.mp3]"
            Back = "忽 (hū)<br><br>suddenly, abruptly<br><br><i>Key pattern word in: 忽近忽远, 忽隐忽现...</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "character", "adverb", "pattern-word")
    },
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

    # Concept Group 3: Building the key phrase 她不停的旋转
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
            Front = "[sound:ta_bu_ting_de_xuan_zhuan.mp3]"
            Back = "她不停的旋转 (tā bù tíng de xuán zhuǎn)<br><br>She keeps on spinning<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "listening", "phrase", "key-lyric", "complete-thought")
    },

    # Concept Group 4: Stage and rhythm concepts
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
)

# Level 1 Reading Cards: Mirror structure of listening cards
$level1ReadingCards = @(
    # Concept Group 1: The "suddenly" pattern
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
    
    # Concept Group 2: More 忽X忽Y patterns
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

    # Concept Group 3: Building the key phrase
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
            Front = "她不停的旋转"
            Back = "[sound:ta_bu_ting_de_xuan_zhuan.mp3]<br><br>(tā bù tíng de xuán zhuǎn) She keeps on spinning<br><br><i>Key phrase from the song</i>"
        }
        tags = @("electronic-girl", "level-1", "reading", "phrase", "key-lyric", "complete-thought")
    },

    # Concept Group 4: Stage and rhythm concepts
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

# Level 2 Listening Cards: Complete Lyric Lines
$level2ListeningCards = @(
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
$level2ReadingCards = @(
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

# Audio file management
$ankiMediaDir = "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"
$localAudioDir = Join-Path $PSScriptRoot "audio"

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
Write-Host "Preparing audio files..."
$audioCopySuccess = Copy-AudioToAnki -SourceDir $localAudioDir -DestinationDir $ankiMediaDir

if (-not $audioCopySuccess) {
    Write-Host "Note: Audio files will need to be manually placed in Anki's media folder."
    Write-Host "Local audio files are available in: $localAudioDir"
}

# Add all cards
Write-Host "`nAdding Level 1 listening cards (Audio → Character + Meaning)..."
foreach ($card in $level1ListeningCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add Level 1 listening card: $($response.error)"
    } else {
        Write-Host "✓ Added Level 1 listening card - ID: $($response.result)"
    }
}

Write-Host "`nAdding Level 1 reading cards (Character → Audio + Meaning)..."
foreach ($card in $level1ReadingCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add Level 1 reading card '$($card.fields.Front)': $($response.error)"
    } else {
        Write-Host "✓ Added Level 1 reading card: $($card.fields.Front) - ID: $($response.result)"
    }
}

Write-Host "`nAdding Level 2 listening cards (Audio → Complete Lines + Meaning)..."
foreach ($card in $level2ListeningCards) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
    
    if ($response.error) {
        Write-Warning "Failed to add Level 2 listening card: $($response.error)"
    } else {
        Write-Host "✓ Added Level 2 listening card - ID: $($response.result)"
    }
}

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

Write-Host "`nDeck structure:"
Write-Host "📚 Chinese Learning - Electronic Girl v3"
Write-Host "  🎧 Level 1 - Building Blocks (Listening)"
Write-Host "  📖 Level 1 - Building Blocks (Reading)"  
Write-Host "  🎧 Level 2 - Complete Lines (Listening)"
Write-Host "  📖 Level 2 - Complete Lines (Reading)"
Write-Host "`nReady to start learning! Begin with Level 1 Building Blocks."
