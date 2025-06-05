#!/usr/bin/env pwsh

# JSON-driven Anki deck creation for Electronic Girl song learning
# This script reads lesson data from JSON files and creates Anki cards dynamically

param(
    [string]$ConfigPath = $PSScriptRoot,
    [switch]$RegenerateAudio = $false,
    [switch]$SkipExisting = $true
)

# Ensure required assemblies are loaded
Add-Type -AssemblyName System.Web

Write-Host "=== JSON-Driven Electronic Girl Anki Deck Creator ===" -ForegroundColor Cyan
Write-Host "Reading lesson configuration from: $ConfigPath" -ForegroundColor Green
Write-Host ""

# Define paths
$localAudioDir = Join-Path $ConfigPath "audio"
$ankiMediaDir = "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"

# JSON lesson files to process
$lessonFiles = @(
    "level-1-building-blocks-listening.json",
    "level-1-building-blocks-reading.json", 
    "level-2-complete-lines-listening.json",
    "level-2-complete-lines-reading.json"
)

# Function to invoke Anki-Connect API
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
    }
    catch {
        Write-Error "Failed to connect to Anki-Connect: $_"
        Write-Host "Make sure Anki is running with the AnkiConnect add-on installed."
        return $null
    }
}

# Function to generate TTS audio file with robust error handling
function Generate-TTSAudio {
    param(
        [string]$ChineseText,
        [string]$FileName,
        [string]$AudioDir,
        [int]$MaxRetries = 3
    )
    
    $filePath = Join-Path $AudioDir $FileName
    
    # Check if file already exists and we're not regenerating
    if ((Test-Path $filePath) -and (-not $RegenerateAudio)) {
        $existingSize = (Get-Item $filePath).Length
        if ($existingSize -gt 100) {
            return $true  # Valid existing file
        } else {
            # Remove invalid small file and regenerate
            Remove-Item $filePath -ErrorAction SilentlyContinue
        }
    }
    
    # Generate the audio file with retry logic
    for ($attempt = 1; $attempt -le $MaxRetries; $attempt++) {
        try {
            Write-Host "  🎵 Generating audio: $FileName (attempt $attempt/$MaxRetries)" -ForegroundColor Yellow
            
            # URL encode the Chinese text
            $encodedText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
            $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$encodedText"
            
            # Use curl with proper error handling
            $curlArgs = @(
                "-A", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
                "-s", "--fail", "--max-time", "30",
                "-o", $filePath,
                $ttsUrl
            )
            
            $curlResult = & curl @curlArgs
            
            if (Test-Path $filePath) {
                $fileSize = (Get-Item $filePath).Length
                if ($fileSize -gt 100) {
                    Write-Host "  ✓ Generated: $FileName ($fileSize bytes)" -ForegroundColor Green
                    return $true
                } else {
                    Write-Warning "  ⚠ Generated file too small: $FileName ($fileSize bytes)"
                    Remove-Item $filePath -ErrorAction SilentlyContinue
                }
            }
            
            # If we get here, the generation failed - wait before retry
            if ($attempt -lt $MaxRetries) {
                $waitTime = $attempt * 2  # Progressive backoff
                Write-Host "  ⏳ Waiting $waitTime seconds before retry..." -ForegroundColor Yellow
                Start-Sleep -Seconds $waitTime
            }
        }
        catch {
            Write-Warning "  ✗ Attempt $attempt failed for $FileName`: $_"
            if ($attempt -lt $MaxRetries) {
                Start-Sleep -Seconds ($attempt * 2)
            }
        }
    }
    
    Write-Error "  ✗ Failed to generate $FileName after $MaxRetries attempts"
    return $false
}

# Function to ensure audio file exists for a card
function Ensure-AudioExists {
    param(
        [string]$AudioFile,
        [string]$ChineseText,
        [string]$AudioDir
    )
    
    if (-not $AudioFile -or -not $ChineseText) {
        return $true  # No audio required
    }
    
    $filePath = Join-Path $AudioDir $AudioFile
    
    # Check if valid audio file exists
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length
        if ($fileSize -gt 100) {
            return $true  # Valid file exists
        }
    }
    
    # Generate the missing audio file
    Write-Host "  📢 Missing audio file: $AudioFile" -ForegroundColor Cyan
    return Generate-TTSAudio -ChineseText $ChineseText -FileName $AudioFile -AudioDir $AudioDir
}

# Function to copy audio files to Anki media directory
function Copy-AudioToAnki {
    param(
        [string]$SourceDir,
        [string]$DestinationDir
    )
    
    if (-not (Test-Path $SourceDir)) {
        Write-Warning "Local audio directory not found: $SourceDir"
        return $false
    }
    
    if (-not (Test-Path $DestinationDir)) {
        Write-Warning "Anki media directory not found: $DestinationDir"
        return $false
    }
    
    $audioFiles = Get-ChildItem -Path $SourceDir -Filter "*.mp3"
    $copiedCount = 0
    
    foreach ($file in $audioFiles) {
        $destPath = Join-Path $DestinationDir $file.Name
        
        try {
            Copy-Item -Path $file.FullName -Destination $destPath -Force
            $copiedCount++
        }
        catch {
            Write-Warning "Failed to copy $($file.Name): $_"
        }
    }
    
    Write-Host "📁 Copied $copiedCount audio files to Anki media directory" -ForegroundColor Green
    return $true
}

# Function to create deck if it doesn't exist
function Ensure-DeckExists {
    param([string]$DeckName)
    
    # Check if deck exists
    $deckListResponse = Invoke-AnkiConnect -Action "deckNames"
    if ($deckListResponse -and $deckListResponse.result -contains $DeckName) {
        Write-Host "  📚 Deck exists: $DeckName" -ForegroundColor Green
        return $true
    }
    
    # Create the deck
    $createResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $DeckName }
    if ($createResponse -and $createResponse.error -eq $null) {
        Write-Host "  📚 Created deck: $DeckName" -ForegroundColor Cyan
        return $true
    } else {
        Write-Warning "  ✗ Failed to create deck: $DeckName - $($createResponse.error)"
        return $false
    }
}

# Function to process cards from a lesson JSON file
function Process-LessonFile {
    param(
        [string]$LessonFilePath
    )
    
    if (-not (Test-Path $LessonFilePath)) {
        Write-Warning "Lesson file not found: $LessonFilePath"
        return @()
    }
    
    try {
        $lessonData = Get-Content $LessonFilePath -Raw | ConvertFrom-Json
        Write-Host "📖 Processing: $($lessonData.deckInfo.name)" -ForegroundColor Cyan
        Write-Host "   $($lessonData.deckInfo.description)" -ForegroundColor Gray
        
        # Ensure deck exists
        if (-not (Ensure-DeckExists -DeckName $lessonData.deckInfo.name)) {
            return @()
        }
        
        $allCards = @()
        
        # Process concept groups (Level 1) or lyric lines (Level 2)
        if ($lessonData.conceptGroups) {
            # Level 1 structure
            foreach ($group in $lessonData.conceptGroups) {
                Write-Host "  📝 Processing group: $($group.groupName)" -ForegroundColor Yellow
                
                foreach ($card in $group.cards) {
                    # Ensure audio file exists (generate if missing)
                    $audioSuccess = Ensure-AudioExists -AudioFile $card.audioFile -ChineseText $card.chineseText -AudioDir $localAudioDir
                    if (-not $audioSuccess -and $card.audioFile) {
                        Write-Warning "  ⚠ Failed to generate audio for: $($card.chineseText)"
                    }
                    
                    # Create Anki card object
                    $ankiCard = @{
                        deckName = $lessonData.deckInfo.name
                        modelName = "Basic"
                        fields = @{
                            Front = $card.front
                            Back = $card.back
                        }
                        tags = @("electronic-girl", "level-$($lessonData.deckInfo.level)", $lessonData.deckInfo.type) + $card.tags
                    }
                    
                    $allCards += $ankiCard
                }
            }
        } elseif ($lessonData.lyricLines) {
            # Level 2 structure
            foreach ($lineGroup in $lessonData.lyricLines) {
                Write-Host "  📝 Processing group: $($lineGroup.groupName)" -ForegroundColor Yellow
                
                foreach ($card in $lineGroup.cards) {
                    # Ensure audio file exists (generate if missing)
                    $audioSuccess = Ensure-AudioExists -AudioFile $card.audioFile -ChineseText $card.chineseText -AudioDir $localAudioDir
                    if (-not $audioSuccess -and $card.audioFile) {
                        Write-Warning "  ⚠ Failed to generate audio for: $($card.chineseText)"
                    }
                    
                    # Create Anki card object
                    $ankiCard = @{
                        deckName = $lessonData.deckInfo.name
                        modelName = "Basic"
                        fields = @{
                            Front = $card.front
                            Back = $card.back
                        }
                        tags = @("electronic-girl", "level-$($lessonData.deckInfo.level)", $lessonData.deckInfo.type) + $card.tags
                    }
                    
                    $allCards += $ankiCard
                }
            }
        }
        
        Write-Host "  ✓ Prepared $($allCards.Count) cards from this lesson" -ForegroundColor Green
        return $allCards
        
    } catch {
        Write-Error "Failed to process lesson file $LessonFilePath`: $_"
        return @()
    }
}

# Function to add cards to Anki
function Add-CardsToAnki {
    param([array]$Cards)
    
    $successCount = 0
    $duplicateCount = 0
    $failureCount = 0
    
    Write-Host ""
    Write-Host "🎴 Adding cards to Anki..." -ForegroundColor Cyan
    
    foreach ($card in $Cards) {
        $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
        
        if ($response.error) {
            if ($response.error -match "duplicate") {
                $duplicateCount++
                if (-not $SkipExisting) {
                    Write-Host "  ⚠ Duplicate: $($card.fields.Front)" -ForegroundColor Yellow
                }
            } else {
                $failureCount++
                Write-Warning "  ✗ Failed: $($card.fields.Front) - $($response.error)"
            }
        } else {
            $successCount++
            Write-Host "  ✓ Added: $($card.fields.Front)" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "📊 Results:" -ForegroundColor Cyan
    Write-Host "  ✓ Successfully added: $successCount cards" -ForegroundColor Green
    if ($duplicateCount -gt 0) {
        Write-Host "  ⚠ Duplicates skipped: $duplicateCount cards" -ForegroundColor Yellow
    }
    if ($failureCount -gt 0) {
        Write-Host "  ✗ Failed: $failureCount cards" -ForegroundColor Red
    }
}

# Main execution
Write-Host "🔍 Checking Anki-Connect connection..."
$connectionTest = Invoke-AnkiConnect -Action "version"
if (-not $connectionTest) {
    Write-Error "Cannot connect to Anki-Connect. Please ensure Anki is running."
    exit 1
}
Write-Host "✓ Connected to Anki-Connect (version $($connectionTest.result))" -ForegroundColor Green

# Ensure audio directory exists
if (-not (Test-Path $localAudioDir)) {
    New-Item -ItemType Directory -Path $localAudioDir -Force | Out-Null
    Write-Host "📁 Created audio directory: $localAudioDir" -ForegroundColor Green
}

# Process all lesson files
$allCards = @()
foreach ($lessonFile in $lessonFiles) {
    $lessonPath = Join-Path $ConfigPath $lessonFile
    $cards = Process-LessonFile -LessonFilePath $lessonPath
    $allCards += $cards
}

if ($allCards.Count -eq 0) {
    Write-Warning "No cards were processed. Please check your JSON lesson files."
    exit 1
}

Write-Host ""
Write-Host "📋 Total cards processed: $($allCards.Count)" -ForegroundColor Cyan

# Copy audio files to Anki
Copy-AudioToAnki -SourceDir $localAudioDir -DestinationDir $ankiMediaDir

# Add all cards to Anki
Add-CardsToAnki -Cards $allCards

Write-Host ""
Write-Host "🎉 Electronic Girl deck creation complete!" -ForegroundColor Green
Write-Host "🎵 You can now study the cards in Anki!" -ForegroundColor Cyan
