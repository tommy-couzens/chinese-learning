# AnkiConnect.ps1 - Functions for interacting with Anki-Connect API

function Invoke-AnkiConnectAPI {
    <#
    .SYNOPSIS
    Invokes an Anki-Connect API action
    
    .DESCRIPTION
    Sends a request to the Anki-Connect API running on localhost:8765
    
    .PARAMETER Action
    The Anki-Connect action to perform
    
    .PARAMETER Params
    Parameters to pass to the action
    
    .PARAMETER Version
    API version to use (default: 6)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Action,
        
        [hashtable]$Params = @{},
        
        [int]$Version = 6
    )
    
    $body = @{
        action = $Action
        version = $Version
        params = $Params
    } | ConvertTo-Json -Depth 10
    
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:8765" -Method Post -Body $body -ContentType "application/json"
        return $response
    }
    catch {
        Write-Error "Failed to connect to Anki-Connect: $_"
        Write-Host "Make sure Anki is running with the AnkiConnect add-on installed." -ForegroundColor Yellow
        return $null
    }
}

function Test-AnkiConnect {
    <#
    .SYNOPSIS
    Tests if Anki-Connect is available and responding
    
    .DESCRIPTION
    Attempts to connect to Anki-Connect and retrieve the version
    #>
    [CmdletBinding()]
    param()
    
    try {
        $response = Invoke-AnkiConnect -Action "version"
        if ($response -and $response.result) {
            Write-Host "✓ Connected to Anki-Connect (version $($response.result))" -ForegroundColor Green
            return $true
        }
        return $false
    }
    catch {
        return $false
    }
}

function Ensure-DeckExists {
    <#
    .SYNOPSIS
    Ensures an Anki deck exists, creating it if necessary
    
    .PARAMETER DeckName
    The name of the deck to ensure exists
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$DeckName
    )
    
    # Check if deck exists
    $deckListResponse = Invoke-AnkiConnect -Action "deckNames"
    if ($deckListResponse -and $deckListResponse.result -contains $DeckName) {
        Write-Host "  📚 Deck exists: $DeckName" -ForegroundColor Green
        return $true
    }
    
    # Create the deck
    $createResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{ deck = $DeckName }
    if ($createResponse -and $createResponse.error -eq $null) {
        Write-Host "  📚 Created deck: $DeckName" -ForegroundColor Cyan
        return $true
    } else {
        Write-Warning "  ✗ Failed to create deck: $DeckName - $($createResponse.error)"
        return $false
    }
}

function Add-CardsToAnki {
    <#
    .SYNOPSIS
    Adds multiple cards to Anki
    
    .PARAMETER Cards
    Array of card objects to add to Anki
    
    .PARAMETER SkipExisting
    Whether to skip reporting duplicate cards
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [array]$Cards,
        
        [switch]$SkipExisting = $true
    )
    
    $successCount = 0
    $duplicateCount = 0
    $failureCount = 0
    
    Write-Host ""
    Write-Host "🎴 Adding cards to Anki..." -ForegroundColor Cyan
    
    foreach ($card in $Cards) {
        $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $card }
        
        if ($response.error) {
            if ($response.error -match "duplicate") {
                $duplicateCount++
                if (-not $SkipExisting) {
                    Write-Host "  ⚠ Duplicate: $($card.fields.Front)" -ForegroundColor Yellow
                }
            } else {
                $failureCount++
                Write-Warning "  ✗ Failed: $($card.fields.Front) - $($response.error)"
            }
        } else {
            $successCount++
            Write-Host "  ✓ Added: $($card.fields.Front)" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "📊 Results:" -ForegroundColor Cyan
    Write-Host "  ✓ Successfully added: $successCount cards" -ForegroundColor Green
    if ($duplicateCount -gt 0) {
        Write-Host "  ⚠ Duplicates skipped: $duplicateCount cards" -ForegroundColor Yellow
    }
    if ($failureCount -gt 0) {
        Write-Host "  ✗ Failed: $failureCount cards" -ForegroundColor Red
    }
    
    return @{
        Success = $successCount
        Duplicates = $duplicateCount
        Failures = $failureCount
    }
}
