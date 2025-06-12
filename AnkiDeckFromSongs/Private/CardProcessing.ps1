# Card Processing Functions for Chinese Learning Module

<#
.SYNOPSIS
    Processes lesson JSON files and converts them to Anki cards
.DESCRIPTION
    Reads lesson configuration from JSON files and creates appropriate Anki card objects
    with proper tagging and content structure
.PARAMETER LessonFilePath
    Path to the JSON lesson file to process
.PARAMETER AudioDir
    Directory where audio files are stored
.PARAMETER SkipExisting
    Whether to skip existing audio files during processing
.PARAMETER SongName
    Name of the song for tagging purposes
.EXAMPLE
    $cards = ConvertFrom-LessonFile -LessonFilePath "level-1.json" -AudioDir "./audio" -SongName "my-good-brother"
#>
function ConvertFrom-LessonFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$LessonFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$AudioDir,
        
        [Parameter(Mandatory = $true)]
        [string]$SongName,
        
        [switch]$SkipExisting = $true
    )
    
    $lessonData = Get-Content $LessonFilePath -Raw | ConvertFrom-Json
    Write-Host "📖 Processing: $($lessonData.deckInfo.name)" -ForegroundColor Cyan
    Write-Host "   $($lessonData.deckInfo.description)" -ForegroundColor Gray
    
    # Check if this is a new format (has conceptGroups)
    if ($lessonData.conceptGroups) {
        Write-Host "   🔄 Using template-based format (conceptGroups found)" -ForegroundColor Magenta
        return ConvertFrom-VocabularyFile -VocabularyFilePath $LessonFilePath -AudioDir $AudioDir -SongName $SongName -SkipExisting:$SkipExisting
    } elseif ($lessonData.deckInfo.cardTemplates -and $lessonData.conceptGroups -and $lessonData.conceptGroups[0].vocabulary) { # Original check, keeping for safety but conceptGroups check above should catch it
        Write-Host "   🔄 Using template-based format (vocabulary array found)" -ForegroundColor Magenta
        return ConvertFrom-VocabularyFile -VocabularyFilePath $LessonFilePath -AudioDir $AudioDir -SongName $SongName -SkipExisting:$SkipExisting
    } else {
        throw "This file format is no longer supported or is missing expected structures like 'conceptGroups' or 'deckInfo'. Please use the new vocabulary-based format for file: $LessonFilePath"
    }
}

<#
.SYNOPSIS
    Adds an array of cards to Anki via AnkiConnect
.DESCRIPTION
    Takes an array of card objects and sends them to Anki via the AnkiConnect API,
    providing progress feedback and error handling
.PARAMETER Cards
    Array of card objects to add to Anki
.PARAMETER SkipExisting
    Whether to skip duplicate cards
.EXAMPLE
    Add-CardsToAnki -Cards $cardArray -SkipExisting
#>
function Add-CardsToAnki {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$Cards,
        
        [switch]$SkipExisting = $true
    )
    
    $successCount = 0
    $duplicateCount = 0
    $failureCount = 0
    
    Write-Host ""
    Write-Host "🎴 Adding cards to Anki..." -ForegroundColor Cyan
    
    foreach ($card in $Cards) {
        $response = Invoke-AnkiConnectAPI -Action "addNote" -Params @{ note = $card }
        
        if ($response.error) {
            if ($response.error -match "duplicate") {
                $duplicateCount++
                # if ($Verbose) { # Changed condition to use Verbose switch
                #     Write-Host "  ⚠ Duplicate: $($card.fields.Front)" -ForegroundColor Yellow
                # }
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

<#
.SYNOPSIS
    Ensures that a deck exists in Anki
.DESCRIPTION
    Checks if the specified deck exists in Anki and creates it if it doesn't
.PARAMETER DeckName
    Name of the deck to ensure exists
.EXAMPLE
    Confirm-DeckExists -DeckName "Chinese -  Electronic Girl"
#>
function Confirm-DeckExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DeckName
    )
    
    # Check if deck exists
    $deckListResponse = Invoke-AnkiConnectAPI -Action "deckNames"
    if ($deckListResponse -and $deckListResponse.result -contains $DeckName) {
        Write-Host "  📚 Deck exists: $DeckName" -ForegroundColor Green
        return $true
    }
    
    # Create the deck
    $createResponse = Invoke-AnkiConnectAPI -Action "createDeck" -Params @{ deck = $DeckName }
    if ($createResponse -and $createResponse.error -eq $null) {
        Write-Host "  📚 Created deck: $DeckName" -ForegroundColor Cyan
        return $true
    } else {
        Write-Warning "  ✗ Failed to create deck: $DeckName - $($createResponse.error)"
        return $false
    }
}
