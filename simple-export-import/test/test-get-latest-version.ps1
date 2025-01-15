# Import the function
. ../compare-versions.ps1
. ../get-latest-version.ps1

# Define the export path
$exportPath = "./exports/test-get-latest-version"

# Clean up any existing version folders for a fresh test
if (Test-Path -Path $exportPath) {
    Remove-Item -Path $exportPath -Recurse -Force
}

# Create the export path
New-Item -ItemType Directory -Path $exportPath

# Create test version folders
$testVersions = @(
    "1.0.0.1",
    "1.0.0.2",
    "1.0.1.0",
    "1.1.0.0",
    "2.0.0.0"
)

foreach ($version in $testVersions) {
    $versionFolder = Join-Path -Path $exportPath -ChildPath $version
    New-Item -ItemType Directory -Path $versionFolder
}

# Call the function to get the latest version
$latestVersion = Get-Latest-Version -ExportPath $exportPath

# Verify the latest version
$expectedVersion = [PSCustomObject]@{
    Major = 2
    Minor = 0
    Build = 0
    Revision = 0
}

if ($latestVersion.Major -eq $expectedVersion.Major -and
    $latestVersion.Minor -eq $expectedVersion.Minor -and
    $latestVersion.Build -eq $expectedVersion.Build -and
    $latestVersion.Revision -eq $expectedVersion.Revision) {
    Write-Host "PASS: Latest version is correct ($($latestVersion.Major).$($latestVersion.Minor).$($latestVersion.Build).$($latestVersion.Revision))"
} else {
    Write-Host "FAIL: Latest version is incorrect. Expected $($expectedVersion.Major).$($expectedVersion.Minor).$($expectedVersion.Build).$($expectedVersion.Revision), got $($latestVersion.Major).$($latestVersion.Minor).$($latestVersion.Build).$($latestVersion.Revision)"
}