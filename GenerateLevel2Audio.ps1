# Generate Missing Audio Files for Level 2 Complete Lines
# This script generates TTS audio for complete lyric lines

Add-Type -AssemblyName System.Web

$audioDir = Join-Path $PSScriptRoot "audio"

# Ensure audio directory exists
if (-not (Test-Path $audioDir)) {
    New-Item -ItemType Directory -Path $audioDir -Force | Out-Null
    Write-Host "Created audio directory: $audioDir"
}

# Function to generate TTS audio using Google Translate
function Generate-TTS-Audio {
    param(
        [string]$ChineseText,
        [string]$FileName
    )
    
    $outputPath = Join-Path $audioDir $FileName
    
    # Skip if file already exists
    if (Test-Path $outputPath) {
        Write-Host "✓ Audio file already exists: $FileName"
        return
    }
    
    # URL encode the Chinese text
    $encodedText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
    $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$encodedText"
    
    try {
        Write-Host "Generating audio for: $ChineseText"
        Invoke-WebRequest -Uri $ttsUrl -OutFile $outputPath -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
        Write-Host "✓ Generated: $FileName"
    }
    catch {
        Write-Warning "Failed to generate $FileName : $_"
    }
}

# Level 2 complete lines that need audio files
$level2AudioNeeded = @(
    @{ text = "她不停的旋转无休止的节拍"; file = "ta_bu_ting_de_xuan_zhuan_wu_xiu_zhi_de_jie_pai.mp3" },
    @{ text = "她不停的旋转在空荡的舞台"; file = "ta_bu_ting_de_xuan_zhuan_zai_kong_dang_de_wu_tai.mp3" },
    @{ text = "她说她是透明的"; file = "ta_shuo_ta_shi_tou_ming_de.mp3" },
    @{ text = "她说她快熄灭了"; file = "ta_shuo_ta_kuai_xi_mie_le.mp3" },
    @{ text = "她说她是电动的"; file = "ta_shuo_ta_shi_dian_dong_de.mp3" }
)

# Also generate any missing basic audio files
$basicAudioNeeded = @(
    @{ text = "不"; file = "bu4.mp3" },
    @{ text = "停"; file = "ting2.mp3" },
    @{ text = "旋"; file = "xuan2.mp3" },
    @{ text = "转"; file = "zhuan3.mp3" },
    @{ text = "旋转"; file = "xuan_zhuan.mp3" },
    @{ text = "的"; file = "de.mp3" }
)

Write-Host "Generating missing basic audio files..."
foreach ($audio in $basicAudioNeeded) {
    Generate-TTS-Audio -ChineseText $audio.text -FileName $audio.file
}

Write-Host "`nGenerating Level 2 complete line audio files..."
foreach ($audio in $level2AudioNeeded) {
    Generate-TTS-Audio -ChineseText $audio.text -FileName $audio.file
}

Write-Host "`nAudio generation complete!"
Write-Host "All audio files are ready in: $audioDir"

# List all audio files
Write-Host "`nCurrent audio files:"
Get-ChildItem -Path $audioDir -Filter "*.mp3" | Sort-Object Name | ForEach-Object {
    Write-Host "  📄 $($_.Name)"
}
