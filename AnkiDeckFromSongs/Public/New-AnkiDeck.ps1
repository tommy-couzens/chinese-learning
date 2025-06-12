function New-AnkiDeck {
    <#
    .SYNOPSIS
        Creates Anki decks from JSON lesson files for learning Chinese songs
    
    .DESCRIPTION
        Processes JSON lesson configuration files to create Anki cards with audio,
        automatically generating TTS audio files and organizing cards into appropriate decks.
        Supports multiple songs organized in the decks/ directory structure.
    
    .PARAMETER SongName
        Name of the song folder to process (e.g., "electronic-girl", "my-little-apple")
    
    .PARAMETER DecksPath
        Path to the decks directory containing song folders (default: ./decks)
    
    .PARAMETER LessonFiles
        Array of specific lesson files to process (default: all JSON files in song folder)
    
    .PARAMETER RegenerateAudio
        Force regeneration of existing audio files
    
    .PARAMETER SkipExisting
        Skip cards that already exist in Anki (default: true)
    
    .EXAMPLE
        New-AnkiDeck -SongName "electronic-girl"
        
    .EXAMPLE
        New-AnkiDeck -SongName "my-little-apple" -RegenerateAudio
        
    .EXAMPLE
        New-AnkiDeck -SongName "electronic-girl" -LessonFiles @("level-1-building-blocks-listening.json") -SkipExisting:$false
    
    .NOTES
        Requires Anki to be running with the AnkiConnect add-on installed.
        Song folders should be organized under decks/ directory.
    #>
    [CmdletBinding()] # Add SupportsShouldProcess if you want to use -WhatIf and -Confirm
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$SongName,
        
        [string]$DecksPath = (Join-Path (Get-Location).Path "decks"),
        
        [string[]]$LessonFiles = @(),
        
        [switch]$RegenerateAudio,
        
        [switch]$SkipExisting
    )
    
    # Ensure required assemblies are loaded
    Add-Type -AssemblyName System.Web
    
    # Determine song directory path
    $songPath = Join-Path $DecksPath $SongName
    if (-not (Test-Path $songPath)) {
        Write-Error "Song directory not found: $songPath"
        Write-Host "Available songs:" -ForegroundColor Yellow
        $availableSongs = Get-ChildItem -Path $DecksPath -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
        foreach ($song in $availableSongs) {
            Write-Host "  - $song" -ForegroundColor Cyan
        }
        return
    }

    $subdecksPath = Join-Path $songPath "subdecks" # Define subdecks path
    
    # If no lesson files specified, find all JSON files in the song's subdecks directory
    if ($LessonFiles.Count -eq 0) {
        if (-not (Test-Path $subdecksPath)) {
            Write-Error "Subdecks directory not found: $subdecksPath"
            return
        }
        $jsonFiles = Get-ChildItem -Path $subdecksPath -Filter "*.json" | Select-Object -ExpandProperty Name
        if ($jsonFiles.Count -eq 0) {
            Write-Error "No JSON lesson files found in: $subdecksPath"
            return
        }
        $LessonFiles = $jsonFiles
    }
    
    Write-Host "=== Chinese Learning Anki Deck Creator ===" -ForegroundColor Cyan
    Write-Host "Processing song: $SongName" -ForegroundColor Green
    Write-Host "Song directory: $songPath" -ForegroundColor Green
    Write-Host "Lesson files: $($LessonFiles -join ', ')" -ForegroundColor Gray
    Write-Host ""
    
    # Define paths
    $localAudioDir = Join-Path $songPath "audio"
    
    # Test Anki-Connect connection
    Write-Host "🔍 Checking Anki-Connect connection..."
    $connectionTest = Invoke-AnkiConnectAPI -Action "version"
    if (-not $connectionTest) {
        Write-Error "Cannot connect to Anki-Connect. Please ensure Anki is running with the AnkiConnect add-on installed."
        return
    }
    Write-Host "✓ Connected to Anki-Connect (version $($connectionTest.result))" -ForegroundColor Green
    
    # Ensure audio directory exists
    if (-not (Confirm-AudioDirectoryExists -AudioDir $localAudioDir)) {
        Write-Error "Failed to create or access audio directory: $localAudioDir"
        return
    }
    
    # Process all lesson files
    $allCards = @()
    foreach ($lessonFile in $LessonFiles) {
        # Construct path to lesson file within the subdecks directory
        $lessonPath = Join-Path $subdecksPath $lessonFile 
        if (Test-Path $lessonPath) {
            $cards = ConvertFrom-LessonFile -LessonFilePath $lessonPath -AudioDir $localAudioDir -SongName $SongName -SkipExisting:$SkipExisting
            $allCards += $cards
        } else {
            Write-Warning "Lesson file not found: $lessonPath"
        }
    }
    
    if ($allCards.Count -eq 0) {
        Write-Warning "No cards were processed. Please check your JSON lesson files."
        return
    }
    
    Write-Host ""
    Write-Host "📋 Total cards processed: $($allCards.Count)" -ForegroundColor Cyan
    
    # Add all cards to Anki
    Add-CardsToAnki -Cards $allCards -SkipExisting:$SkipExisting
    
    Write-Host ""
    Write-Host "🎉 Chinese Learning deck creation complete!" -ForegroundColor Green
    Write-Host "🎵 You can now study the cards in Anki!" -ForegroundColor Cyan
}
