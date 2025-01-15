. ./compare-versions.ps1

function Get-Latest-Version {
    param (
        [string]$ExportPath
    )

    if (-not (Test-Path -Path $ExportPath)) {
        Write-Host "Export path does not exist: $ExportPath"
        return $null
    }

    $existingVersionFolders = Get-ChildItem -Path $ExportPath -Directory | Where-Object { $_.Name -match '^\d+\.\d+\.\d+\.\d+$' }
    $latestExistingVersion = $null

    foreach ($folder in $existingVersionFolders) {
        $versionParts = $folder.Name -split '\.'
        $folderVersion = [PSCustomObject]@{
            Major = [int]$versionParts[0]
            Minor = [int]$versionParts[1]
            Build = [int]$versionParts[2]
            Revision = [int]$versionParts[3]
        }

        if ($null -eq $latestExistingVersion -or (Is-GreaterVersionThan -Version1 $folderVersion -Version2 $latestExistingVersion) -gt 0) {
            $latestExistingVersion = $folderVersion
        }
    }

    return $latestExistingVersion
}