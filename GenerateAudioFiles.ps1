# Script to generate TTS audio files for the Electronic Girl deck
# This script downloads audio files from Google TTS and saves them to Anki's media folder

param(
    [string]$AnkiMediaPath = "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"
)

# Function to download TTS audio
function Get-ChineseTTS {
    param(
        [string]$ChineseText,
        [string]$OutputPath
    )
    
    try {
        # URL encode the Chinese text
        $encodedText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
        $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$encodedText"
        
        Write-Host "Downloading TTS for: $ChineseText"
        
        # Download the audio file
        Invoke-WebRequest -Uri $ttsUrl -OutFile $OutputPath -UserAgent "Mozilla/5.0"
        
        Write-Host "✓ Saved: $OutputPath"
        return $true
    }
    catch {
        Write-Error "Failed to download TTS for '$ChineseText': $_"
        return $false
    }
}

# Audio files to generate for the Electronic Girl deck
$audioFiles = @(
    @{ text = "忽"; filename = "hu1.mp3" },
    @{ text = "近"; filename = "jin4.mp3" },
    @{ text = "远"; filename = "yuan3.mp3" },
    @{ text = "她"; filename = "ta1.mp3" },
    @{ text = "不停"; filename = "bu_ting.mp3" },
    @{ text = "忽近忽远"; filename = "hu_jin_hu_yuan.mp3" },
    @{ text = "忽隐忽现"; filename = "hu_yin_hu_xian.mp3" },
    @{ text = "忽明忽暗"; filename = "hu_ming_hu_an.mp3" },
    @{ text = "忽快忽慢"; filename = "hu_kuai_hu_man.mp3" },
    @{ text = "她不停的旋转"; filename = "ta_bu_ting_de_xuan_zhuan.mp3" },
    @{ text = "无休止的节拍"; filename = "wu_xiu_zhi_de_jie_pai.mp3" },
    @{ text = "在空荡的舞台"; filename = "zai_kong_dang_de_wu_tai.mp3" }
)

# Check if Anki media directory exists
if (-not (Test-Path $AnkiMediaPath)) {
    Write-Warning "Anki media directory not found at: $AnkiMediaPath"
    Write-Host "Please update the path or create the directory manually."
    Write-Host "Default Anki media paths:"
    Write-Host "  Windows: %APPDATA%\Anki2\User 1\collection.media"
    Write-Host "  macOS: ~/Library/Application Support/Anki2/User 1/collection.media"
    Write-Host "  Linux: ~/.local/share/Anki2/User 1/collection.media"
    
    # Create a local audio directory instead
    $localAudioPath = Join-Path $PSScriptRoot "audio"
    if (-not (Test-Path $localAudioPath)) {
        New-Item -ItemType Directory -Path $localAudioPath | Out-Null
    }
    $AnkiMediaPath = $localAudioPath
    Write-Host "Using local directory: $AnkiMediaPath"
}

Write-Host "Starting TTS audio generation..."
Write-Host "Output directory: $AnkiMediaPath"

$successCount = 0
$totalCount = $audioFiles.Count

foreach ($audioFile in $audioFiles) {
    $outputPath = Join-Path $AnkiMediaPath $audioFile.filename
    
    # Skip if file already exists
    if (Test-Path $outputPath) {
        Write-Host "⏭️  Skipping (already exists): $($audioFile.filename)"
        $successCount++
        continue
    }
    
    if (Get-ChineseTTS -ChineseText $audioFile.text -OutputPath $outputPath) {
        $successCount++
    }
    
    # Add a small delay to be respectful to the TTS service
    Start-Sleep -Milliseconds 500
}

Write-Host "`n📊 Generation complete!"
Write-Host "✅ Successfully generated: $successCount/$totalCount files"

if ($AnkiMediaPath -like "*audio*" -and $AnkiMediaPath -notlike "*Anki2*") {
    Write-Host "`n📁 Audio files are in: $AnkiMediaPath"
    Write-Host "To use with Anki, copy these files to your Anki media folder:"
    Write-Host "  Windows: %APPDATA%\Anki2\User 1\collection.media"
    Write-Host "  macOS: ~/Library/Application Support/Anki2/User 1/collection.media"
    Write-Host "  Linux: ~/.local/share/Anki2/User 1/collection.media"
}
