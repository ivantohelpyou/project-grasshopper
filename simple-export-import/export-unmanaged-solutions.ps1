param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Config
)

# Import functions
. ./get-solution-version.ps1
. ./is-greaterversionthan.ps1
. ./ensure-export-path.ps1
. ./get-latest-version.ps1
. ./export-solution.ps1
. ./handle-solution-export.ps1
. ./authenticate.ps1

function Process-Environment {
    param (
        [PSCustomObject]$Env
    )

    Write-Host "Processing environment: $($Env.url)"

    # Authenticate with the environment
    Authenticate -EnvironmentUrl $Env.url

    # Export unmanaged solutions
    foreach ($solutionName in $Env.unmanagedSolutions) {
        Write-Host "Getting solution version for: $solutionName"
        $currentVersion = Get-SolutionVersion -EnvironmentUrl $Env.url -SolutionUniqueName $solutionName
        if ($null -eq $currentVersion) {
            Write-Error "Failed to get solution version for $solutionName in environment $($Env.url)"
            continue
        }
        $versionString = "$($currentVersion.Major).$($currentVersion.Minor).$($currentVersion.Build).$($currentVersion.Revision)"
        $exportPath = "./exports/" + ($Env.url -replace 'https://|\.crm\.dynamics\.com', '') + "/$solutionName/$versionString"
        Ensure-Export-Path -ExportPath $exportPath
        Handle-Solution-Export -EnvironmentUrl $Env.url -SolutionName $solutionName -ExportPath $exportPath
    }
}

function Validate-Config {
    param (
        [PSCustomObject]$Config
    )

    if (-not $Config.environments) {
        Write-Error "Invalid configuration: 'environments' field is missing."
        return $false
    }

    foreach ($env in $Config.environments) {
        if (-not $env.url) {
            Write-Error "Invalid configuration: 'url' field is missing in one of the environments."
            return $false
        }

        if (-not $env.unmanagedSolutions) {
            Write-Error "Invalid configuration: 'unmanagedSolutions' field is missing in environment $($env.url)."
            return $false
        }
    }

    return $true
}

# Validate the configuration
if (-not (Validate-Config -Config $Config)) {
    exit 1
}

# Loop through environments and export unmanaged solutions
foreach ($env in $Config.environments) {
    Process-Environment -Env $env
}

return $true