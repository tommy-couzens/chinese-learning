# Tests for Card Templating System
# These tests verify the new template-based card generation system

BeforeAll {
    Remove-Module AnkiDeckFromSongs -Force -ErrorAction SilentlyContinue # Ensure module commands don't interfere
    
    # Import the module
    # Import-Module "$PSScriptRoot/../AnkiDeckFromSongs.psd1" -Force
    . $PSScriptRoot/../private/AudioGeneration.ps1
    . $PSScriptRoot/../private/CardProcessing.ps1
    . $PSScriptRoot/../private/CardTemplating.ps1
    
    # Create test template directory
    $testTemplateDir = "$PSScriptRoot/test-templates"
    if (-not (Test-Path $testTemplateDir)) {
        New-Item -Path $testTemplateDir -ItemType Directory
    }        # Create test template
        $testTemplate = @{
            templateName = "test-listening"
            description = "Test template for listening cards"
            cardStructure = @{
                front = "[sound:{{audioFileName}}]"
                back = "{{chineseText}} ({{pinyin}})<br><br>{{englishText}}<br><br>{{explanation}}"
                audioFile = "{{audioFileName}}"
                chineseText = "{{chineseText}}"
                translation = "{{englishText}}"
            }
            requiredFields = @("name", "chineseText", "pinyin", "englishText")
            optionalFields = @("explanation")
        }
    
    $testTemplate | ConvertTo-Json -Depth 5 | Out-File "$testTemplateDir/test-listening.json"
}

AfterAll {
    # Clean up
    if (Test-Path "$PSScriptRoot/test-templates") {
        Remove-Item "$PSScriptRoot/test-templates" -Recurse -Force
    }
}

Describe "Expand-Template" {
    It "Should replace simple template variables" {
        $template = "Hello {{name}}, welcome to {{place}}"
        $variables = @{
            name = "World"
            place = "China"
        }
        
        $result = Expand-Template -Template $template -Variables $variables
        $result | Should -Be "Hello World, welcome to China"
    }
    
    It "Should handle empty variables" {
        $template = "{{chineseText}} ({{pinyin}})<br><br>{{englishText}}<br><br>{{explanation}}"
        $variables = @{
            chineseText = "你好"
            pinyin = "nǐ hǎo"
            englishText = "hello"
            explanation = ""
        }
        
        $result = Expand-Template -Template $template -Variables $variables
        $result | Should -Be "你好 (nǐ hǎo)<br><br>hello"
    }
    
    It "Should clean up empty explanation patterns" {
        $template = "{{chineseText}}<br><br>{{englishText}}<br><br>{{explanation}}"
        $variables = @{
            chineseText = "风"
            englishText = "wind"
            explanation = ""
        }
        
        $result = Expand-Template -Template $template -Variables $variables
        $result | Should -Be "风<br><br>wind"
    }
}

Describe "New-CardFromTemplate" {
    BeforeEach {
        # Mock template
        $template = [PSCustomObject]@{
            templateName = "test-listening"
            requiredFields = @("name", "chineseText", "pinyin", "englishText")
            cardStructure = [PSCustomObject]@{
                front = "[sound:{{audioFileName}}]"
                back = "{{chineseText}} ({{pinyin}})<br><br>{{englishText}}<br><br>{{explanation}}"
            }
        }
        
        # Test vocabulary item
        $vocabItem = [PSCustomObject]@{
            name = "feng1"
            pinyin = "fēng"
            chineseText = "风"
            englishText = "wind"
            explanation = "Natural force"
        }
    }
    
    It "Should create a card from template and vocabulary data" {
        $card = New-CardFromTemplate -VocabularyItem $vocabItem -Template $template
        
        $card | Should -Not -BeNullOrEmpty
        $card.front | Should -Be "[sound:feng1.mp3]"
        $card.back | Should -Be "风 (fēng)<br><br>wind<br><br><i>Natural force</i>"
        $card.audioFile | Should -Be "feng1.mp3"
        $card.chineseText | Should -Be "风"
        $card.translation | Should -Be "wind"
    }
    
    It "Should return null for missing required fields" {
        # Remove required field
        $incompleteVocab = [PSCustomObject]@{
            name = "test"
            chineseText = "测试"
            englishText = "test"
            # Missing pinyin
        }
        
        $card = New-CardFromTemplate -VocabularyItem $incompleteVocab -Template $template -ErrorAction SilentlyContinue
        $card | Should -BeNullOrEmpty
    }
}

Describe "Integration Test - Vocabulary Data Processing" {
    BeforeEach {
        # Create test vocabulary data file
        $testVocabData = @{
            deckInfo = @{
                name = "Test Deck::Level 1"
                description = "Test vocabulary deck"
                level = 1
                type = "mixed"
                cardTemplates = @("test-listening") # Use "test-listening" to match the mock
            }
            conceptGroups = @(
                @{
                    groupName = "Test Group"
                    description = "Test vocabulary group"
                    vocabulary = @(
                        @{
                            name = "feng1"
                            pinyin = "fēng"
                            chineseText = "风"
                            englishText = "wind"
                            explanation = "Natural force"
                        }
                    )
                }
            )
        }
        
        $testDataFile = "$PSScriptRoot/test-vocab-data.json"
        $testVocabData | ConvertTo-Json -Depth 5 | Out-File $testDataFile
        
        # Create test audio directory
        $testAudioDir = "$PSScriptRoot/test-audio"
        if (-not (Test-Path $testAudioDir)) {
            New-Item -Path $testAudioDir -ItemType Directory
        }
        
        # Create dummy audio file
        "dummy audio content" | Out-File "$testAudioDir/feng1.mp3"
    }
    
    AfterEach {
        # Clean up
        @("$PSScriptRoot/test-vocab-data.json", "$PSScriptRoot/test-audio") | ForEach-Object {
            if (Test-Path $_) {
                Remove-Item $_ -Recurse -Force
            }
        }
    }
    
    It "Should detect new vocabulary format and process correctly" {
        # Mock the external functions that we can't easily test
        Mock Confirm-DeckExists { return $true }
        Mock Get-CardTemplate {
            param([string]$TemplateName) # Parameterize the mock

            if ($TemplateName -eq "test-listening") {
                # Return a complete and correct template object,
                # matching the structure of "test-listening.json" from BeforeAll.
                return [PSCustomObject]@{
                    templateName   = "test-listening"
                    description    = "Test template for listening cards" # Matches BeforeAll
                    cardStructure  = [PSCustomObject]@{
                        front       = "[sound:{{audioFileName}}]"
                        back        = "{{chineseText}} ({{pinyin}})<br><br>{{englishText}}<br><br>{{explanation}}"
                        audioFile   = "{{audioFileName}}"       # Matches BeforeAll
                        chineseText = "{{chineseText}}"       # Matches BeforeAll
                        translation = "{{englishText}}"       # Matches BeforeAll
                    }
                    requiredFields = @("name", "chineseText", "pinyin", "englishText") # Matches BeforeAll, includes "name"
                    optionalFields = @("explanation") # Matches BeforeAll
                }
            } else {
                # If called for any other template, return $null to simulate 'not found'.
                return $null
            }
        }
        Mock Confirm-AudioExists { return $true }
        
        $cards = ConvertFrom-LessonFile -LessonFilePath "$PSScriptRoot/test-vocab-data.json" -AudioDir "$PSScriptRoot/test-audio" -SongName "test-song"
        
        $cards | Should -Not -BeNullOrEmpty
        $cards.Count | Should -BeGreaterThan 0
        $cards[0].fields.Front | Should -Be "[sound:feng1.mp3]"
        $cards[0].fields.Back | Should -Match "风.*fēng.*wind"
    }
}

Describe "Template Validation Tests" {
    It "Should validate listening template structure" {
        $templatePath = "$PSScriptRoot/../card-templates/listening.json"
        $templatePath | Should -Exist
        
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        $template.templateName | Should -Be "listening"
        $template.cardStructure.front | Should -Match "\{\{audioFileName\}\}"
        $template.cardStructure.back | Should -Match "\{\{chineseText\}\}.*\{\{pinyin\}\}.*\{\{englishText\}\}"
        $template.requiredFields | Should -Contain "chineseText"
        $template.requiredFields | Should -Contain "pinyin"
        $template.requiredFields | Should -Contain "englishText"
    }
    
    It "Should validate chinese-reading template structure" {
        $templatePath = "$PSScriptRoot/../card-templates/chinese-reading.json"
        $templatePath | Should -Exist
        
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        $template.templateName | Should -Be "chinese-reading"
        $template.cardStructure.front | Should -Match "\{\{chineseText\}\}"
        $template.cardStructure.back | Should -Match "\{\{audioFileName\}\}.*\{\{pinyin\}\}.*\{\{englishText\}\}"
    }
    
    It "Should validate english-reading template structure" {
        $templatePath = "$PSScriptRoot/../card-templates/english-reading.json"
        $templatePath | Should -Exist
        
        $template = Get-Content $templatePath -Raw | ConvertFrom-Json
        $template.templateName | Should -Be "english-reading"
        $template.cardStructure.front | Should -Match "\{\{englishText\}\}"
        $template.cardStructure.back | Should -Match "\{\{chineseText\}\}.*\{\{pinyin\}\}"
    }
}
