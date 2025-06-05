# File Operations Functions for Chinese Learning Module

<#
.SYNOPSIS
    Copies audio files from source directory to Anki media directory
.DESCRIPTION
    Takes all MP3 files from the source audio directory and copies them to the
    Anki media directory where they can be used in cards
.PARAMETER SourceDir
    Source directory containing audio files
.PARAMETER DestinationDir
    Anki media directory destination
.EXAMPLE
    Copy-AudioToAnkiMedia -SourceDir "./audio" -DestinationDir "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"
#>
function Copy-AudioToAnkiMedia {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceDir,
        
        [Parameter(Mandatory = $true)]
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

<#
.SYNOPSIS
    Ensures that the audio directory exists
.DESCRIPTION
    Creates the audio directory if it doesn't exist
.PARAMETER AudioDir
    Path to the audio directory to ensure exists
.EXAMPLE
    Confirm-AudioDirectoryExists -AudioDir "./audio"
#>
function Confirm-AudioDirectoryExists {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$AudioDir
    )
    
    if (-not (Test-Path $AudioDir)) {
        try {
            New-Item -ItemType Directory -Path $AudioDir -Force | Out-Null
            Write-Host "📁 Created audio directory: $AudioDir" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Error "Failed to create audio directory: $AudioDir - $_"
            return $false
        }
    }
    
    return $true
}

<#
.SYNOPSIS
    Gets the default Anki media directory path
.DESCRIPTION
    Returns the standard Anki media directory path for the current platform
.EXAMPLE
    $ankiMediaDir = Get-AnkiMediaDirectory
#>
function Get-AnkiMediaDirectory {
    [CmdletBinding()]
    param()
    
    if ($IsWindows) {
        return "$env:APPDATA\Anki2\User 1\collection.media"
    }
    elseif ($IsMacOS) {
        return "$env:HOME/Library/Application Support/Anki2/User 1/collection.media"
    }
    elseif ($IsLinux) {
        return "$env:HOME/.local/share/Anki2/User 1/collection.media"
    }
    else {
        # Fallback for older PowerShell versions
        if ($env:OS -eq "Windows_NT") {
            return "$env:APPDATA\Anki2\User 1\collection.media"
        }
        else {
            return "$env:HOME/.local/share/Anki2/User 1/collection.media"
        }
    }
}
