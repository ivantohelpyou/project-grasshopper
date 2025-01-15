# Load configuration
$config = Get-Content -Raw -Path "deploy-config.json" | ConvertFrom-Json
$spName = $config.servicePrincipalName

if (-not $spName) {
    Write-Error "Service principal name is not specified in the configuration."
    exit 1
}

# Function to check the last exit code and exit if it is non-zero
function Test-LastExitCode {
    if ($LASTEXITCODE -ne 0) {
        Write-Error "The last command failed with exit code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
}

# Check if service principal exists
$sp = az ad sp list --all --query "[?displayName=='$spName'].appId" -o tsv
Test-LastExitCode

if ($sp) {
    Write-Output "Service principal '$spName' exists with AppId: $sp"
} else {
    Write-Output "Service principal '$spName' does not exist. Creating it now..."
    $sp = az ad sp create-for-rbac --name $spName --skip-assignment | ConvertFrom-Json
    Test-LastExitCode
    Write-Output "Service principal '$spName' created with AppId: $($sp.appId)"
    Write-Output "Client Secret: $($sp.password)"
}