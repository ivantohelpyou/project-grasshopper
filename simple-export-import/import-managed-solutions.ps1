param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject]$Config
)

# Import functions
. ./get-solution-version.ps1
. ./get-latest-version.ps1
. ./authenticate.ps1

function Get-LatestSolutionFilePath {
    param (
        [string]$ExportPath,
        [string]$SolutionName
    )

    # { Write-Host "Checking export path: $ExportPath" }

    if (-not (Test-Path -Path $ExportPath)) {
        Write-Error "Export path does not exist: $ExportPath"
        return $null, $null
    }

    # Get the latest version folder
    $latestVersionFolder = Get-Latest-Version -ExportPath $ExportPath

    if ($null -eq $latestVersionFolder) {
        Write-Error "No exported version found for solution $SolutionName in $ExportPath"
        return $null, $null
    }

    $exportedVersion = "$($latestVersionFolder.Major).$($latestVersionFolder.Minor).$($latestVersionFolder.Build).$($latestVersionFolder.Revision)"
    $solutionFilePath = "$ExportPath/$exportedVersion/$exportedVersion/${SolutionName}_managed.zip"

    # { Write-Host "Checking solution file path: $solutionFilePath" }

    if (-not (Test-Path -Path $solutionFilePath)) {
        Write-Error "Solution file not found at $solutionFilePath"
        return $null, $null
    }

    return $solutionFilePath, $exportedVersion
}

function Process-Solution {
    param (
        [PSCustomObject]$Env,
        [string]$SolutionName,
        [string]$ParentEnvironment
    )

    Write-Host "Importing managed solution: $SolutionName into environment: $($Env.url) from parent environment: $ParentEnvironment"

    # Get the export path for the solution
    $exportPath = "./exports/" + ($ParentEnvironment -replace 'https://|\.crm\.dynamics\.com', '') + "/$SolutionName"
    $solutionFilePath, $exportedVersion = Get-LatestSolutionFilePath -ExportPath $exportPath -SolutionName $SolutionName

    if ($null -eq $solutionFilePath) {
        return
    }

    # Import the solution
    Invoke-SolutionImport -EnvironmentUrl $Env.url -SolutionName $SolutionName -SolutionFilePath $solutionFilePath
}

function Process-Environment {
    param (
        [PSCustomObject]$Env
    )

    Write-Host "Processing environment: $($Env.url)"

    foreach ($solution in $Env.managedSolutions) {
        Process-Solution -Env $Env -SolutionName $solution.name -ParentEnvironment $solution.parentEnvironment
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

function Invoke-SolutionImport {
    param (
        [string]$EnvironmentUrl,
        [string]$SolutionName,
        [string]$SolutionFilePath
    )

    Write-Host "Importing solution from $SolutionFilePath"
    pac solution import --path $SolutionFilePath --environment $EnvironmentUrl --skip-lower-version
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to import solution $SolutionName from $SolutionFilePath into environment $EnvironmentUrl"
        return $false
    }

    Write-Host "Successfully imported solution $SolutionName into environment $EnvironmentUrl"
    return $true
}

# Validate the configuration
if (-not (Validate-Config -Config $Config)) {
    exit 1
}

# Check if the /exports directory exists
$exportsPath = "./exports"
# { Write-Host "Checking /exports directory: $exportsPath" }

if (-not (Test-Path -Path $exportsPath)) {
    Write-Error "/exports directory does not exist: $exportsPath"
    exit 1
}

# Loop through environments and import managed solutions
foreach ($env in $Config.environments) {
    # Authenticate with the current environment
    Authenticate -EnvironmentUrl $env.url

    Process-Environment -Env $env
}

# { Write-Host "All managed solutions imported successfully." }
return $true