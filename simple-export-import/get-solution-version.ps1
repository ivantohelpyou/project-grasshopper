param (
    [string]$EnvironmentUrl,
    [string]$SolutionUniqueName
)

function Get-SolutionVersion {
    param (
        [string]$EnvironmentUrl,
        [string]$SolutionUniqueName
    )

    Write-Host "Getting solutions in environment: $EnvironmentUrl"
    $solutionsOutput = pac solution list --environment $EnvironmentUrl
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to get solutions in environment $EnvironmentUrl"
        return $null
    }

    # Split the output into lines and find the line containing the solution unique name
    $solutionLine = $solutionsOutput -split "`n" | Where-Object { $_ -match $SolutionUniqueName }

    if ($solutionLine) {
        Write-Host "Found solution line: $solutionLine"

        # Extract the version number using a regular expression
        if ($solutionLine -match '\s+(\d+)\.(\d+)\.(\d+)\.(\d+)\s+') {
            $version = [PSCustomObject]@{
                Major = [int]$matches[1]
                Minor = [int]$matches[2]
                Build = [int]$matches[3]
                Revision = [int]$matches[4]
            }
            Write-Host "Found version: $($version.Major).$($version.Minor).$($version.Build).$($version.Revision)"
            return $version
        } else {
            Write-Error "Version number not found in solution line"
            return $null
        }
    } else {
        Write-Host "Solution $SolutionUniqueName not found in environment $EnvironmentUrl"
        return $null
    }
}
