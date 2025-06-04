#!/usr/bin/env pwsh

# Generate missing Level 2 audio files for Electronic Girl deck
# These are complete lyric lines that weren't generated in the original audio set

$audioDir = Join-Path $PSScriptRoot "audio"

# Ensure audio directory exists
if (-not (Test-Path $audioDir)) {
    New-Item -ItemType Directory -Path $audioDir -Force
    Write-Host "Created audio directory: $audioDir"
}

# Function to generate TTS audio file
function Generate-TTSAudio {
    param(
        [string]$ChineseText,
        [string]$FileName,
        [string]$AudioDir
    )
    
    $filePath = Join-Path $AudioDir $FileName
    
    # Check if file already exists
    if (Test-Path $filePath) {
        Write-Host "✓ Audio file already exists: $FileName"
        return $true
    }
    
    try {
        # URL encode the Chinese text
        $encodedText = [System.Web.HttpUtility]::UrlEncode($ChineseText)
        $ttsUrl = "https://translate.google.com/translate_tts?ie=UTF-8&tl=zh-cn&client=tw-ob&q=$encodedText"
        
        Write-Host "Generating: $FileName for text '$ChineseText'"
        Write-Host "TTS URL: $ttsUrl"
        
        # Use curl to download the audio file
        $curlCommand = "curl -A 'Mozilla/5.0' -s '$ttsUrl' -o '$filePath'"
        Invoke-Expression $curlCommand
        
        if (Test-Path $filePath) {
            $fileSize = (Get-Item $filePath).Length
            if ($fileSize -gt 100) {  # Basic check that we got actual audio data
                Write-Host "✓ Successfully generated: $FileName (Size: $fileSize bytes)"
                return $true
            } else {
                Write-Warning "Generated file seems too small, might be an error response"
                Remove-Item $filePath -ErrorAction SilentlyContinue
                return $false
            }
        } else {
            Write-Warning "Failed to generate audio file: $FileName"
            return $false
        }
    }
    catch {
        Write-Error "Error generating $FileName`: $_"
        return $false
    }
}

# Level 2 complete lyric lines that need audio files
$level2AudioFiles = @(
    @{ Text = "她不停的旋转无休止的节拍"; File = "ta_bu_ting_de_xuan_zhuan_wu_xiu_zhi_de_jie_pai.mp3" },
    @{ Text = "她不停的旋转在空荡的舞台"; File = "ta_bu_ting_de_xuan_zhuan_zai_kong_dang_de_wu_tai.mp3" },
    @{ Text = "她说她是透明的"; File = "ta_shuo_ta_shi_tou_ming_de.mp3" },
    @{ Text = "她说她快熄灭了"; File = "ta_shuo_ta_kuai_xi_mie_le.mp3" },
    @{ Text = "她说她是电动的"; File = "ta_shuo_ta_shi_dian_dong_de.mp3" },
    @{ Text = "在夜里闪烁的光"; File = "zai_ye_li_shan_shuo_de_guang.mp3" },
    @{ Text = "她是一个电动女孩"; File = "ta_shi_yi_ge_dian_dong_nu_hai.mp3" },
    @{ Text = "忽近忽远忽隐忽现"; File = "hu_jin_hu_yuan_hu_yin_hu_xian.mp3" }
)

Write-Host "Generating Level 2 audio files for complete lyric lines..."
Write-Host "Audio directory: $audioDir"
Write-Host ""

$successCount = 0
$totalCount = $level2AudioFiles.Count

foreach ($audioItem in $level2AudioFiles) {
    $success = Generate-TTSAudio -ChineseText $audioItem.Text -FileName $audioItem.File -AudioDir $audioDir
    if ($success) {
        $successCount++
    }
    Start-Sleep -Milliseconds 500  # Small delay to be respectful to the API
}

Write-Host ""
Write-Host "Audio generation complete!"
Write-Host "Successfully generated: $successCount/$totalCount files"
Write-Host "Audio files are available in: $audioDir"

if ($successCount -eq $totalCount) {
    Write-Host "✓ All Level 2 audio files generated successfully!"
} else {
    Write-Warning "Some audio files failed to generate. You may need to retry or generate them manually."
}
