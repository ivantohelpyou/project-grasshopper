. ./get-solution-version.ps1
. ./compare-versions.ps1
. ./get-latest-version.ps1
. ./export-solution.ps1

function Handle-Solution-Export {
    param (
        [string]$EnvironmentUrl,
        [string]$SolutionName,
        [string]$ExportPath
    )

    Write-Host "Handling export for solution '$SolutionName' from environment '$EnvironmentUrl' to path '$ExportPath'..."

    # Ensure the export path exists
    if (-not (Test-Path -Path $ExportPath)) {
        Write-Host "Export path does not exist. Creating export path: $ExportPath"
        New-Item -ItemType Directory -Path $ExportPath -Force
    }

    # Get the version of the solution in the environment
    $currentVersion = Get-SolutionVersion -EnvironmentUrl $EnvironmentUrl -SolutionUniqueName $SolutionName

    # Debug: Print the current version
    Write-Host "Current version: $($currentVersion.Major).$($currentVersion.Minor).$($currentVersion.Build).$($currentVersion.Revision)"

    # Get the latest existing version from the folder names
    $latestExistingVersion = Get-Latest-Version -ExportPath $ExportPath

    if ($null -ne $latestExistingVersion) {
        Write-Host "Latest existing version: $($latestExistingVersion.Major).$($latestExistingVersion.Minor).$($latestExistingVersion.Build).$($latestExistingVersion.Revision)"

        # Compare versions
        $comparisonResult = Compare-Versions -Version1 $latestExistingVersion -Version2 $currentVersion
        if ($comparisonResult -eq 0) {
            Write-Host "The existing solution file is up-to-date. Skipping export."
            return
        } elseif ($comparisonResult -gt 0) {
            Write-Warning "The existing solution version ($($latestExistingVersion.Major).$($latestExistingVersion.Minor).$($latestExistingVersion.Build).$($latestExistingVersion.Revision)) is newer than the current version ($($currentVersion.Major).$($currentVersion.Minor).$($currentVersion.Build).$($currentVersion.Revision)). Skipping export."
            return
        } else {
            Write-Host "A newer version of the solution is available. Proceeding with export."
        }
    } else {
        Write-Host "No existing version folder found. Proceeding with export."
    }

    # Debug: Print the solution name before export
    Write-Host "Exporting solution with name: $SolutionName"

    # Call the function to export the solution
    Export-Solution -EnvironmentUrl $EnvironmentUrl -SolutionName $SolutionName -ExportPath $ExportPath -Version $currentVersion
}