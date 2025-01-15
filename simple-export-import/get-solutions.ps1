function Get-Solutions {
    param (
        [string]$EnvironmentUrl
    )

    $solutionsOutput = pac solution list --environment $EnvironmentUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to get solutions in environment $EnvironmentUrl"
        exit $LASTEXITCODE
    }

    if ($Verbose) {
        # Debug: Print raw output
        Write-Host $solutionsOutput
    }

    return $solutionsOutput
}