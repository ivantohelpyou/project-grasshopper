param keyVaultName string
param storageAccountName string
param storageContainerName string
param location string = resourceGroup().location
param servicePrincipalName string

// Create Service Principal
resource sp 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: servicePrincipalName
  location: location
}

// Create Key Vault
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: sp.properties.principalId
        permissions: {
          keys: ['get', 'list']
          secrets: ['get', 'list']
          certificates: ['get', 'list']
        }
      }
    ]
  }
}

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// Blob Services Resource
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: 'default'
  parent: storageAccount
}

// Storage Container Resource
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-04-01' = {
  name: storageContainerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}

// Check if Role Assignment for Key Vault exists
resource existingKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
  scope: keyVault
  name: guid(subscription().id, keyVault.id, sp.name)
}

// Assign Role to Service Principal for Key Vault if it doesn't already exist
resource keyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (existingKeyVaultRoleAssignment.id == null) {
  name: guid(subscription().id, keyVault.id, sp.name)
  properties: {
    principalId: sp.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7') // Key Vault Contributor role
  }
}

// Check if Role Assignment for Storage Account exists
resource existingStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' existing = {
  scope: storageAccount
  name: guid(subscription().id, storageAccount.id, sp.name)
}

// Assign Role to Managed Identity for Storage Account if it doesn't already exist
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = if (existingStorageRoleAssignment.id == null) {
  name: guid(subscription().id, storageAccount.id, sp.name)
  properties: {
    principalId: sp.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor role
  }
}

// Outputs
output principalId string = sp.properties.principalId
output keyVaultName string = keyVault.name
output storageAccountName string = storageAccount.name
output storageContainerName string = storageContainer.name
