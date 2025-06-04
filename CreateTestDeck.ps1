# Function to make API requests to Anki-Connect
function Invoke-AnkiConnect {
    param(
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
    } catch {
        Write-Error "Failed to connect to Anki-Connect: $_"
        return $null
    }
}

# Create a test deck
$deckName = "PowerShell Test Deck"
Write-Host "Creating deck: $deckName"

$createDeckResponse = Invoke-AnkiConnect -Action "createDeck" -Params @{
    deck = $deckName
}

if ($createDeckResponse.error) {
    Write-Error "Failed to create deck: $($createDeckResponse.error)"
} else {
    Write-Host "Deck created successfully with ID: $($createDeckResponse.result)"
}

# Add some test notes to the deck
$testNotes = @(
    @{
        deckName = $deckName
        modelName = "Basic"
        fields = @{
            Front = "What is the capital of France?"
            Back = "Paris"
        }
        tags = @("geography", "europe")
    },
    @{
        deckName = $deckName
        modelName = "Basic"
        fields = @{
            Front = "What is 2 + 2?"
            Back = "4"
        }
        tags = @("math", "basic")
    },
    @{
        deckName = $deckName
        modelName = "Basic"
        fields = @{
            Front = "What is the largest planet in our solar system?"
            Back = "Jupiter"
        }
        tags = @("astronomy", "science")
    }
)

Write-Host "Adding test notes..."

foreach ($note in $testNotes) {
    $response = Invoke-AnkiConnect -Action "addNote" -Params @{ note = $note }
    
    if ($response.error) {
        Write-Warning "Failed to add note '$($note.fields.Front)': $($response.error)"
    } else {
        Write-Host "Added note with ID: $($response.result)"
    }
}

Write-Host "Test deck creation complete!"

# Optional: Get deck statistics
$statsResponse = Invoke-AnkiConnect -Action "getDeckStats" -Params @{
    decks = @($deckName)
}

if ($statsResponse.result) {
    $stats = $statsResponse.result.PSObject.Properties.Value | Select-Object -First 1
    Write-Host "Deck stats - Total cards: $($stats.total_in_deck), New: $($stats.new_count)"
}