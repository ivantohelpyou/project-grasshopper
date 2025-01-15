# Import the required functions
. ./ensure-export-path.ps1

function Export-Solution {
    param (
        [string]$EnvironmentUrl,
        [string]$SolutionName,
        [string]$ExportPath,
        [PSCustomObject]$Version
    )

    Write-Host "Exporting solution '$SolutionName' from environment '$EnvironmentUrl' to path '$ExportPath'..."

    # Debug: Print the Version parameter
    Write-Host "Version parameter: Major=$($Version.Major), Minor=$($Version.Minor), Build=$($Version.Build), Revision=$($Version.Revision)"

    # Create the version string
    $versionString = "$($Version.Major).$($Version.Minor).$($Version.Build).$($Version.Revision)"
    Write-Host "Version string: $versionString"

    # Create a subfolder for the version
    $versionFolder = "$ExportPath\$versionString"
    Write-Host "Creating version folder: $versionFolder"
    Ensure-Export-Path -ExportPath $versionFolder

    # Verify the creation of the subfolder
    if (-not (Test-Path -Path $versionFolder)) {
        Write-Error "Failed to create version folder: $versionFolder"
        exit 1
    }

    # Export the solution to the version subfolder
    Write-Host "Exporting solution to: $versionFolder"
    pac solution export --name $SolutionName --path $versionFolder --managed --overwrite
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to export solution $SolutionName from environment $EnvironmentUrl"
        exit $LASTEXITCODE
    }

    Write-Host "Successfully exported solution $SolutionName from environment $EnvironmentUrl to $versionFolder"
}