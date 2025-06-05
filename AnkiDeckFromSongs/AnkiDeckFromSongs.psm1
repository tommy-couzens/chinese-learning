# AnkiDeckFromSongs.psm1 - Main module file for Chinese Learning Anki deck creation

# Import all private functions
$privateScripts = Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1"
foreach ($script in $privateScripts) {
    . $script.FullName
}

# Import all public functions  
$publicScripts = Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -ErrorAction SilentlyContinue
foreach ($script in $publicScripts) {
    . $script.FullName
}

# Export public functions
$publicFunctions = $publicScripts | ForEach-Object { 
    [System.IO.Path]::GetFileNameWithoutExtension($_.Name) 
}

if ($publicFunctions) {
    Export-ModuleMember -Function $publicFunctions
}

Write-Verbose "AnkiDeckFromSongs module loaded successfully"
