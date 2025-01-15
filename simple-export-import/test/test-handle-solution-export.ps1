# Import the functions
. ../get-solution-version.ps1
. ../compare-versions.ps1
. ../ensure-export-path.ps1
. ../get-latest-version.ps1
. ../export-solution.ps1
. ../handle-solution-export.ps1

# Define the environment URL, solution name, and export path
$environmentUrl = "https://mztape-apps.crm.dynamics.com"
$solutionName = "MztapeApps"
$exportPath = "./exports/mztape-apps"

function Clean-Up {
    param (
        [string]$Path
    )
    # Clean up any existing version folders for a fresh test
    $existingVersionFolders = Get-ChildItem -Path $Path -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' }
    foreach ($folder in $existingVersionFolders) {
        Remove-Item -Path $folder.FullName -Recurse -Force
    }
}

# Case 1: No existing version
Write-Host "Case 1: No existing version"
Clean-Up -Path $exportPath
Handle-Solution-Export -EnvironmentUrl $environmentUrl -SolutionName $solutionName -ExportPath $exportPath

# Verify the export
$versionFolder = Join-Path -Path $exportPath -ChildPath "1.0.2.4"
$solutionFilePath = Join-Path -Path $versionFolder -ChildPath "${solutionName}_managed.zip"
if (Test-Path -Path $solutionFilePath) {
    Write-Host "Exported solution found at: $solutionFilePath"
} else {
    Write-Error "Export failed: Solution file not found."
}

# Case 2: Existing version is older
Write-Host "Case 2: Existing version is older"
Clean-Up -Path $exportPath
$olderVersionFolder = Join-Path -Path $exportPath -ChildPath "1.0.2.3"
Ensure-Export-Path -ExportPath $olderVersionFolder

Handle-Solution-Export -EnvironmentUrl $environmentUrl -SolutionName $solutionName -ExportPath $exportPath

# Verify the export again
$solutionFilePath = Join-Path -Path $versionFolder -ChildPath "${solutionName}_managed.zip"
if (Test-Path -Path $solutionFilePath) {
    Write-Host "Exported solution found at: $solutionFilePath"
} else {
    Write-Error "Export failed after update: Solution file not found."
}

# Case 3: Existing version is newer
Write-Host "Case 3: Existing version is newer"
Clean-Up -Path $exportPath
$newerVersionFolder = Join-Path -Path $exportPath -ChildPath "1.0.2.5"
Ensure-Export-Path -ExportPath $newerVersionFolder

Handle-Solution-Export -EnvironmentUrl $environmentUrl -SolutionName $solutionName -ExportPath $exportPath

# Verify that no new export was created
if (Test-Path -Path $solutionFilePath) {
    Write-Error "Export should not have occurred, but solution file found at: $solutionFilePath"
} else {
    Write-Host "No new export occurred as expected."
}