# Import the functions
. ../ensure-export-path.ps1
. ../export-solution.ps1

# Define the environment URL, solution name, export path, and version
$environmentUrl = "https://mztape-base.crm.dynamics.com"
$solutionName = "MztapeBaseLayer"
$exportPath = "./exports/mztape-base"
$version = [PSCustomObject]@{
    Major = 1
    Minor = 0
    Build = 0
    Revision = 7
}

# Clean up any existing version folders for a fresh test
$existingVersionFolders = Get-ChildItem -Path $exportPath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' }
foreach ($folder in $existingVersionFolders) {
    Remove-Item -Path $folder.FullName -Recurse -Force
}

# Call the function to export the solution
Export-Solution -EnvironmentUrl $environmentUrl -SolutionName $solutionName -ExportPath $exportPath -Version $version

# Verify the export
$versionFolder = Join-Path -Path $exportPath -ChildPath "1.0.0.7"
$solutionFilePath = Join-Path -Path $versionFolder -ChildPath "${solutionName}_managed.zip"
Write-Host "Expected solution file path: $solutionFilePath"
if (Test-Path -Path $solutionFilePath) {
    Write-Host "Exported solution found at: $solutionFilePath"
} else {
    Write-Host "Files in version folder:"
    Get-ChildItem -Path $versionFolder -Force
    Write-Error "Export failed: Solution file not found."
}