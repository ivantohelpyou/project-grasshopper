targetScope = 'subscription'

// Parameters
param location string = 'westus2'
param resourceGroupName string = 'mztape-config'

// Create Resource Group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}
