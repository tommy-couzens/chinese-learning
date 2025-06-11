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
        throw "Local audio source directory not found: $SourceDir"
    }
    
    if (-not (Test-Path $DestinationDir)) {
        throw "Anki media destination directory not found: $DestinationDir"
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
.PARAMETER ProfileName
    The name of the Anki profile to get the media directory for
.EXAMPLE
    $ankiMediaDir = Get-AnkiMediaDirectory -ProfileName "User 1"
#>
function Get-AnkiMediaDirectory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ProfileName
    )
    
    if ($IsWindows) {
        return "$env:APPDATA\\Anki2\\$ProfileName\\collection.media"
    }
    elseif ($IsMacOS) {
        return "$env:HOME/Library/Application Support/Anki2/$ProfileName/collection.media"
    }
    elseif ($IsLinux) {
        return "$env:HOME/.local/share/Anki2/$ProfileName/collection.media"
    }
    else {
        # Fallback for older PowerShell versions or unknown OS
        if ($env:OS -eq "Windows_NT") {
            return "$env:APPDATA\\Anki2\\$ProfileName\\collection.media"
        }
        else {
            # Defaulting to Linux-like path for unknown non-Windows
            return "$env:HOME/.local/share/Anki2/$ProfileName/collection.media"
        }
    }
}
