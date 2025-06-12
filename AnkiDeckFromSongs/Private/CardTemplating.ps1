# Card Templating Functions for Chinese Learning Module

<#
.SYNOPSIS
    Loads card template definitions
.DESCRIPTION
    Reads card template JSON files and returns template objects
.PARAMETER TemplateName
    Name of the template to load (e.g., "listening", "chinese-reading", "english-reading")
.EXAMPLE
    $template = Get-CardTemplate -TemplateName "listening"
#>
function Get-CardTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplateName
    )
    
    $templatePath = Join-Path $PSScriptRoot "../card-templates/$TemplateName.json"
    
    if (-not (Test-Path $templatePath)) {
        Write-Error "Template file not found: $templatePath"
        return $null
    }
    
    try {
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        return $template
    }
    catch {
        Write-Error "Failed to parse template file: $templatePath - $_"
        return $null
    }
}

<#
.SYNOPSIS
    Creates cards from vocabulary data using card templates
.DESCRIPTION
    Takes vocabulary data and applies card templates to generate Anki cards
.PARAMETER VocabularyItem
    Vocabulary item with fields like name, pinyin, chineseText, englishText, explanation, tags
.PARAMETER Template
    Card template object containing the card structure
.PARAMETER AudioFileExtension
    Audio file extension (default: .mp3)
.EXAMPLE
    $card = New-CardFromTemplate -VocabularyItem $vocab -Template $template
#>
function New-CardFromTemplate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$VocabularyItem,
        
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$Template,
        
        [string]$AudioFileExtension = ".mp3"
    )
    
    # Validate required fields for the vocabulary item itself
    $requiredVocabFields = @("name", "chineseText", "englishText", "pinyin") # Added pinyin
    foreach ($field in $requiredVocabFields) {
        if (-not $VocabularyItem.PSObject.Properties[$field] -or [string]::IsNullOrWhiteSpace($VocabularyItem.$field)) {
            Write-Error "Vocabulary item based on name '$($VocabularyItem.name)' (or first item if name is also missing) is missing or has empty required field: '$($field)'. ChineseText: '$($VocabularyItem.chineseText)'"
            # Throw an exception to halt processing for this file
            throw "Critical error in vocabulary item structure. Halting processing for this file."
            return $null # Should not be reached due to throw
        }
    }

    # Validate required fields based on the template (original logic)
    foreach ($requiredField in $Template.requiredFields) {
        if (-not $VocabularyItem.PSObject.Properties[$requiredField]) {
            Write-Error "Vocabulary item missing required field: $requiredField"
            return $null
        }
    }
    
    # Create audio filename from name
    $audioFileName = "$($VocabularyItem.name)$AudioFileExtension"
    
    # Prepare template variables
    $templateVars = @{
        audioFileName = $audioFileName
        chineseText = $VocabularyItem.chineseText
        pinyin = $VocabularyItem.pinyin
        englishText = $VocabularyItem.englishText
        explanation = if ($VocabularyItem.explanation) { "<i>$($VocabularyItem.explanation)</i>" } else { "" }
    }
    
    # Apply template to create card
    $card = @{
        front = Expand-Template -Template $Template.cardStructure.front -Variables $templateVars
        back = Expand-Template -Template $Template.cardStructure.back -Variables $templateVars
        audioFile = $audioFileName
        chineseText = $VocabularyItem.chineseText
        translation = $VocabularyItem.englishText
    }
    
    return $card
}

<#
.SYNOPSIS
    Expands template strings with variable substitution
.DESCRIPTION
    Replaces {{variableName}} placeholders in template strings with actual values
.PARAMETER Template
    Template string containing {{variable}} placeholders
.PARAMETER Variables
    Hashtable of variable names and values
.EXAMPLE
    $result = Expand-Template -Template "Hello {{name}}" -Variables @{name="World"}
#>
function Expand-Template {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Template,
        
        [Parameter(Mandatory = $true)]
        [hashtable]$Variables
    )
    
    $result = $Template
    
    foreach ($key in $Variables.Keys) {
        $placeholder = "{{$key}}"
        $value = $Variables[$key]
        
        # Handle empty/null values
        if ([string]::IsNullOrEmpty($value)) {
            $value = ""
        }
        
        $result = $result -replace [regex]::Escape($placeholder), $value
    }
    
    # Clean up any remaining empty explanation patterns
    $result = $result -replace '<br><br><i></i>', ''
    $result = $result -replace '<br><br>$', ''
    
    return $result
}

<#
.SYNOPSIS
    Processes vocabulary data files and converts them to Anki cards using templates
.DESCRIPTION
    Reads vocabulary data JSON files and creates appropriate Anki card objects using card templates
.PARAMETER VocabularyFilePath
    Path to the JSON vocabulary data file to process
.PARAMETER AudioDir
    Directory where audio files are stored
.PARAMETER SongName
    Name of the song for tagging purposes
.PARAMETER SkipExisting
    Whether to skip existing audio files during processing
.EXAMPLE
    $cards = ConvertFrom-VocabularyFile -VocabularyFilePath "level-1-data.json" -AudioDir "./audio" -SongName "electronic-girl"
#>
function ConvertFrom-VocabularyFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ })]
        [string]$VocabularyFilePath,
        
        [Parameter(Mandatory = $true)]
        [string]$AudioDir,
        
        [Parameter(Mandatory = $true)]
        [string]$SongName,
        
        [switch]$SkipExisting = $true
    )
    
    try {
        $vocabularyData = Get-Content $VocabularyFilePath -Raw | ConvertFrom-Json
        Write-Host "📖 Processing: $($vocabularyData.deckInfo.name)" -ForegroundColor Cyan
        Write-Host "   $($vocabularyData.deckInfo.description)" -ForegroundColor Gray
        
        # Ensure single deck exists
        if (-not (Confirm-DeckExists -DeckName $vocabularyData.deckInfo.name)) {
            return @()
        }
        
        # Load card templates in desired order: listening, chinese-reading, english-reading
        $templateOrder = @("listening", "chinese-reading", "english-reading")
        $templates = @()
        
        foreach ($templateName in $templateOrder) {
            if ($vocabularyData.deckInfo.cardTemplates -contains $templateName) {
                $template = Get-CardTemplate -TemplateName $templateName
                if ($template) {
                    $templates += $template
                } else {
                    Write-Warning "Failed to load template: $templateName"
                }
            }
        }
        
        if ($templates.Count -eq 0) {
            Write-Error "No valid templates found for deck: $($vocabularyData.deckInfo.name)"
            return @()
        }
        
        $allCards = @()
        
        # Process concept groups
        foreach ($group in $vocabularyData.conceptGroups) {
            Write-Host "  📝 Processing group: $($group.groupName)" -ForegroundColor Yellow
            
            $itemsToProcess = @()
            if ($group.PSObject.Properties['vocabulary'] -and $null -ne $group.vocabulary) {
                $itemsToProcess = $group.vocabulary
            } elseif ($group.PSObject.Properties['concepts'] -and $null -ne $group.concepts) {
                $itemsToProcess = $group.concepts
            } else {
                Write-Warning "Group '$($group.groupName)' in file '$($VocabularyFilePath)' has neither a 'vocabulary' nor a 'concepts' array. Skipping this group."
                continue
            }

            foreach ($item in $itemsToProcess) { # Changed from $vocabItem to $item
                # Ensure audio file exists (generate if missing)
                # Check if 'name' property exists and is not empty, otherwise skip audio generation for this item
                if (-not $item.PSObject.Properties['name'] -or [string]::IsNullOrWhiteSpace($item.name)) {
                    Write-Warning "  ⚠ Item with ChineseText '$($item.chineseText)' is missing a 'name' property or it is empty. Skipping audio generation and card creation as 'name' is required for audio filename and card processing."
                    continue # Skip this item if name is missing, as it's crucial
                }

                $audioFileName = "$($item.name).mp3"
                $audioSuccess = Confirm-AudioExists -AudioFile $audioFileName -ChineseText $item.chineseText -AudioDir $AudioDir
                if (-not $audioSuccess) {
                    Write-Warning "  ⚠ Failed to generate audio for: $($item.chineseText)"
                }
                
                # Create cards from each template in order for this vocabulary item
                foreach ($template in $templates) {
                    $card = New-CardFromTemplate -VocabularyItem $item -Template $template # Changed from $vocabItem to $item
                    if ($card) {
                        # Determine audio target fields based on template type
                        $audioTargetFields = if ($template.templateName -eq "listening") { @("Front") } else { @("Back") }
                        
                        # Prepare audio data for AnkiConnect if audioFile exists
                        $noteAudio = @()
                        if ($card.audioFile -and (Test-Path (Join-Path $AudioDir $card.audioFile))) {
                            $absoluteAudioPath = (Resolve-Path (Join-Path $AudioDir $card.audioFile)).Path
                            $noteAudio = @(
                                @{
                                    path = $absoluteAudioPath
                                    filename = $card.audioFile
                                    fields = $audioTargetFields
                                    skipHash = (Get-FileHash $absoluteAudioPath -Algorithm MD5).Hash
                                }
                            )
                        }
                        
                        # Create Anki card object
                        $ankiCard = @{
                            deckName = $vocabularyData.deckInfo.name
                            modelName = "Basic"
                            fields = @{
                                Front = $card.front
                                Back = $card.back
                            }
                            tags = @($SongName, "level-$($vocabularyData.deckInfo.level)", $template.templateName)
                        }
                        
                        if ($noteAudio.Count -gt 0) {
                            $ankiCard.Add("audio", $noteAudio)
                        }
                        
                        $allCards += $ankiCard
                    }
                }
            }
        }
        
        Write-Host "  ✓ Prepared $($allCards.Count) cards from this vocabulary file" -ForegroundColor Green
        return $allCards
        
    } catch {
        throw "Failed to process vocabulary file $VocabularyFilePath`: $_"
        return @()
    }
}
