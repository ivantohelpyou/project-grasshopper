# Load configuration from JSON file
$config = Get-Content -Raw -Path "./deploy-config.json" | ConvertFrom-Json

# Paths to Bicep files
$CREATE_RG_BICEP_PATH = "./create-resource-group.bicep"
$CREATE_RESOURCES_BICEP_PATH = "./create-resources.bicep"

# Function to check the last exit code and exit if not successful
function Test-LastExitCode {
    if ($LASTEXITCODE -ne 0) {
        Write-Error "The last command failed with exit code $LASTEXITCODE. Exiting script."
        exit $LASTEXITCODE
    }
}

# Function to test Key Vault name
function Test-KeyVaultName {
    param (
        [string]$name
    )
    if ($name.Length -lt 3 -or $name.Length -gt 24) {
        throw "Key Vault name must be between 3 and 24 characters."
    }
    if ($name -notmatch '^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$') {
        throw "Key Vault name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens."
    }
    if ($name -match '--') {
        throw "Key Vault name must not contain consecutive hyphens."
    }
}

# Test Key Vault name
Test-KeyVaultName -name $config.keyVaultName

# Generate a unique suffix
function New-UniqueSuffix {
    param (
        [int]$length = 8
    )
    return -join ((48..57) + (97..122) | Get-Random -Count $length | ForEach-Object { [char]$_ })
}

# Generate a unique suffix
$uniqueSuffix = New-UniqueSuffix

# Generate unique names for Key Vault and Storage Account using the same suffix
$uniqueKeyVaultName = "$($config.keyVaultName)$uniqueSuffix"
$uniqueStorageAccountName = "$($config.storageAccountName)$uniqueSuffix"

# Ensure storage account name is lowercase
$uniqueStorageAccountName = $uniqueStorageAccountName.ToLower()

# Use the default container name from the config file
$storageContainerName = $config.storageContainerName

# Check if already logged in
$accountInfo = az account show --query "{name:name, user:user.name}" -o json | ConvertFrom-Json
if (-not $accountInfo) {
    # Authenticate with Azure
    Write-Host "Please log in to your Azure account..."
    az login --tenant $($config.tenantId) --allow-no-subscriptions
    Test-LastExitCode
} else {
    Write-Host "Already logged in as $($accountInfo.user)"
}

# Set the default subscription if not already set
$currentSubscription = az account show --query "id" -o tsv
if ($currentSubscription -ne $($config.subscriptionId)) {
    Write-Host "Setting the default subscription..."
    az account set --subscription $($config.subscriptionId)
    Test-LastExitCode
} else {
    Write-Host "Subscription already set to $($config.subscriptionId)"
}

# Check if Resource Group exists
$rgExists = az group exists --name $($config.resourceGroupName)
if ($rgExists -eq "false") {
    # Create Resource Group using Bicep
    az deployment sub create --location $($config.location) --template-file $CREATE_RG_BICEP_PATH --parameters location=$($config.location) resourceGroupName=$($config.resourceGroupName)
    Test-LastExitCode
} else {
    Write-Host "Resource Group $($config.resourceGroupName) already exists. Skipping creation."
}

# Deploy the Service Principal, Key Vault, and Storage Account
az deployment group create --resource-group $($config.resourceGroupName) --template-file $CREATE_RESOURCES_BICEP_PATH --parameters servicePrincipalName=$($config.servicePrincipalName) keyVaultName=$uniqueKeyVaultName storageAccountName=$uniqueStorageAccountName storageContainerName=$storageContainerName location=$($config.location)
Test-LastExitCode

Write-Host "Deployment completed successfully."
Write-Host "Generated Key Vault Name: $uniqueKeyVaultName"
Write-Host "Generated Storage Account Name: $uniqueStorageAccountName"
Write-Host "Storage Container Name: $storageContainerName"