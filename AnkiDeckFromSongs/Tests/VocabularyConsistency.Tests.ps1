Describe 'Vocabulary Consistency Tests' {
    $lyricsPath = Resolve-Path '/Users/tommy.couzens/personal/chinese-learning/decks/electronic-girl/lyrics.txt'
    $lyricsContent = Get-Content -Path $lyricsPath -Raw
    $subdecksPath = Resolve-Path '/Users/tommy.couzens/personal/chinese-learning/decks/electronic-girl/subdecks'

    $jsonFiles = Get-ChildItem -Path $subdecksPath -Filter *.json -ErrorAction SilentlyContinue

    if ($null -eq $jsonFiles -or $jsonFiles.Count -eq 0) {
        It "should find JSON files in $($subdecksPath)" {
            $jsonFiles | Should -Not -BeNull
            Write-Warning "No JSON files found in $($subdecksPath). Ensure files have been moved to the 'subdecks' subfolder."
        }
    } else {
        foreach ($jsonFileItem in $jsonFiles) {
            Context "$($jsonFileItem.Name) against lyrics.txt" {
                $lessonJsonPath = $jsonFileItem.FullName
                $lessonData = Get-Content -Path $lessonJsonPath -Raw | ConvertFrom-Json

                if ($null -ne $lessonData.conceptGroups) {
                    foreach ($group in $lessonData.conceptGroups) {
                        $itemsToTest = @()
                        if ($null -ne $group.vocabulary) {
                            $itemsToTest = $group.vocabulary
                        } elseif ($null -ne $group.concepts) {
                            $itemsToTest = $group.concepts
                        }

                        if ($itemsToTest.Count -gt 0) {
                            foreach ($item in $itemsToTest) {
                                if ($item.PSObject.Properties.Match('chineseText')) {
                                    $chineseText = $item.chineseText
                                    if (-not [string]::IsNullOrWhiteSpace($chineseText)) {
                                        It "should find '$($chineseText)' from group '$($group.groupName)' in $($jsonFileItem.Name)" {
                                            $lyricsContent | Should -Contain $chineseText
                                        }
                                    }
                                }
                            }
                        } else {
                            # It's possible a group might legitimately have no vocab/concepts, so this might be too strict.
                            # Consider if this test is necessary for all cases.
                            # It "group '$($group.groupName)' in $($jsonFileItem.Name) should have vocabulary or concepts" {
                            #    $false | Should -BeTrue -Because "Group '$($group.groupName)' has no vocabulary or concepts defined."
                            # }
                        }
                    }
                } else {
                    It "$($jsonFileItem.Name) should have conceptGroups" {
                        $lessonData.conceptGroups | Should -Not -BeNull
                    }
                }
            }
        }
    }
}
