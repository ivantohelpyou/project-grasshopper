# Relative path to the load-config.ps1 file and configuration file
$configPath = "./simple-export.json"
$loadConfigPath = "./load-config.ps1"

# Load configuration
.. $loadConfigPath
$config = Load-Config -ConfigPath $configPath

# Import functions
. ../get-latest-version.ps1

function Get-LatestSolutionFolder {
    param (
        [string]$ExportPath,
        [string]$SolutionName
    )

    # { Write-Host "Checking export path: $ExportPath" }

    if (-not (Test-Path -Path $ExportPath)) {
        Write-Error "Export path does not exist: $ExportPath"
        return $null
    }

    # Get the latest version folder
    $latestVersionFolder = Get-Latest-Version -ExportPath $ExportPath

    if ($null -eq $latestVersionFolder) {
        Write-Error "No exported version found for solution $SolutionName in $ExportPath"
        return $null
    }

    $latestVersion = "$($latestVersionFolder.Major).$($latestVersionFolder.Minor).$($latestVersionFolder.Build).$($latestVersionFolder.Revision)"
    $solutionFolderPath = "$ExportPath/$latestVersion/$latestVersion"

    # { Write-Host "Checking solution folder path: $solutionFolderPath" }

    if (-not (Test-Path -Path $solutionFolderPath)) {
        Write-Error "Solution folder not found at $solutionFolderPath"
        return $null
    }

    return $solutionFolderPath
}

function List-SolutionFolders {
    param (
        [PSCustomObject]$Env
    )

    # { Write-Host "Processing environment: $($Env.url)" }

    foreach ($solution in $Env.managedSolutions) {
        $solutionName = $solution.name
        $parentEnvironment = $solution.parentEnvironment
        # { Write-Host "Listing folder for managed solution: $solutionName in environment: $($Env.url) from parent environment: $parentEnvironment" }

        # Get the export path for the solution
        $exportPath = "./exports/" + ($parentEnvironment -replace 'https://|\.crm\.dynamics\.com', '') + "/$solutionName"
        # { Write-Host "Checking environment folder path: $exportPath" }

        if (-not (Test-Path -Path $exportPath)) {
            Write-Error "Environment folder does not exist: $exportPath"
            continue
        }

        $solutionFolderPath = Get-LatestSolutionFolder -ExportPath $exportPath -SolutionName $solutionName

        if ($null -ne $solutionFolderPath) {
            # { Write-Host "Latest version folder for ${solutionName}: ${solutionFolderPath}" }
        }
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

        if (-not $env.managedSolutions) {
            $env.managedSolutions = @()
        }

        foreach ($solution in $env.managedSolutions) {
            if (-not $solution.name) {
                Write-Error "Invalid configuration: 'name' field is missing in one of the managed solutions in environment $($env.url)."
                return $false
            }

            if (-not $solution.parentEnvironment) {
                Write-Error "Invalid configuration: 'parentEnvironment' field is missing in managed solution $($solution.name) in environment $($env.url)."
                return $false
            }
        }
    }

    # { Write-Host "Configuration validation passed." }
    return $true
}

# Validate the configuration
if (-not (Validate-Config -Config $config)) {
    exit 1
}

# Check if the /exports directory exists
$exportsPath = "./exports"
# { Write-Host "Checking /exports directory: $exportsPath" }

if (-not (Test-Path -Path $exportsPath)) {
    Write-Error "/exports directory does not exist: $exportsPath"
    exit 1
}

# Loop through environments and list solution folders
foreach ($env in $config.environments) {
    List-SolutionFolders -Env $env
}

# { Write-Host "All solution folders listed successfully." }
return $true