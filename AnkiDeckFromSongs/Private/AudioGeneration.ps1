# AudioGeneration.ps1 - Functions for generating TTS audio files

function Initialize-AudioDirectory {
    <#
    .SYNOPSIS
    Ensures the audio directory exists
    
    .PARAMETER AudioDir
    Path to the audio directory
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AudioDir
    )
    
    if (-not (Test-Path $AudioDir)) {
        New-Item -ItemType Directory -Path $AudioDir -Force | Out-Null
        Write-Host "📁 Created audio directory: $AudioDir" -ForegroundColor Green
    }
}

function New-TTSAudio {
    <#
    .SYNOPSIS
    Generates a TTS audio file from Chinese text
    
    .PARAMETER ChineseText
    The Chinese text to convert to speech
    
    .PARAMETER FileName
    The output filename for the audio file
    
    .PARAMETER AudioDir
    Directory to save the audio file
    
    .PARAMETER MaxRetries
    Maximum number of retry attempts
    
    .PARAMETER Force
    Force regeneration even if file exists
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ChineseText,
        
        [Parameter(Mandatory)]
        [string]$FileName,
        
        [Parameter(Mandatory)]
        [string]$AudioDir,
        
        [int]$MaxRetries = 3,
        
        [switch]$Force
    )
    
    # Ensure required assembly is loaded
    Add-Type -AssemblyName System.Web
    
    $filePath = Join-Path $AudioDir $FileName
    
    # Check if file already exists and we're not forcing regeneration
    if ((Test-Path $filePath) -and (-not $Force)) {
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

function Test-AudioFile {
    <#
    .SYNOPSIS
    Tests if an audio file exists and is valid
    
    .PARAMETER AudioFile
    The audio filename to test
    
    .PARAMETER AudioDir
    Directory containing the audio file
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$AudioFile,
        
        [Parameter(Mandatory)]
        [string]$AudioDir
    )
    
    $filePath = Join-Path $AudioDir $AudioFile
    
    if (Test-Path $filePath) {
        $fileSize = (Get-Item $filePath).Length
        return $fileSize -gt 100  # Basic size check
    }
    
    return $false
}

function Ensure-AudioExists {
    <#
    .SYNOPSIS
    Ensures an audio file exists for a card, generating it if missing
    
    .PARAMETER AudioFile
    The audio filename
    
    .PARAMETER ChineseText
    The Chinese text for TTS generation
    
    .PARAMETER AudioDir
    Directory for audio files
    
    .PARAMETER Force
    Force regeneration even if file exists
    #>
    [CmdletBinding()]
    param(
        [string]$AudioFile,
        [string]$ChineseText,
        [Parameter(Mandatory)]
        [string]$AudioDir,
        [switch]$Force
    )
    
    if (-not $AudioFile -or -not $ChineseText) {
        return $true  # No audio required
    }
    
    # Check if valid audio file exists
    if ((Test-AudioFile -AudioFile $AudioFile -AudioDir $AudioDir) -and (-not $Force)) {
        return $true  # Valid file exists
    }
    
    # Generate the missing audio file
    Write-Host "  📢 Missing audio file: $AudioFile" -ForegroundColor Cyan
    return New-TTSAudio -ChineseText $ChineseText -FileName $AudioFile -AudioDir $AudioDir -Force:$Force
}

function Confirm-AudioExists {
    <#
    .SYNOPSIS
    Ensures that an audio file exists for a card, generating it if missing
    
    .PARAMETER AudioFile
    Name of the audio file
    
    .PARAMETER ChineseText
    Chinese text to generate audio for
    
    .PARAMETER AudioDir
    Directory where audio files are stored
    
    .PARAMETER Force
    Force regeneration even if file exists
    #>
    [CmdletBinding()]
    param(
        [string]$AudioFile,
        
        [string]$ChineseText,
        
        [Parameter(Mandatory)]
        [string]$AudioDir,
        
        [switch]$Force
    )
    
    if (-not $AudioFile -or -not $ChineseText) {
        return $true  # No audio required
    }
    
    # Check if valid audio file exists
    if ((Test-AudioFile -AudioFile $AudioFile -AudioDir $AudioDir) -and (-not $Force)) {
        return $true  # Valid file exists
    }
    
    # Generate the missing audio file
    Write-Host "  📢 Missing audio file: $AudioFile" -ForegroundColor Cyan
    return New-TTSAudio -ChineseText $ChineseText -FileName $AudioFile -AudioDir $AudioDir -Force:$Force
}
