targetScope = 'subscription'

param adminPrincipalId string
param applicationPrincipalId string = ''
//try to create something unique based on sub name
param uniqueSuffix string = uniqueString(subscription().displayName, rgName)

param rgLocation string {
  default: 'westus'
  allowed: [
    'westus'
    'westus2'
    'eastus'
    'eastus2'
  ]
}

param rgName string {
  default: 'rg-shrd-mgmt'
  maxLength: 90
  minLength: 1
}

param logAnalyticsName string {
  default: take(concat('la-shrd-mgmt-', uniqueSuffix), 63)
  maxLength: 63
  minLength: 4
}
param keyValutName string {
  default: take(concat('kv-shrd-mgmt-', uniqueSuffix), 24)
  maxLength: 24
  minLength: 3
}

param keyValutDiagName string = 'diag-kv-shrd-mgmt'

//put what ever tags you want on all these resources
var defaultTags = {
  brought_to_you_by: 'management'
}

//https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var readerDefinitionId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7'
var logAnalyticsContributorDefinitionId = '92aaf0da-9dab-42b6-94a3-d43ce8d16293'

//Assign subscription reader role to principal ID provided
resource subRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  //Just trying to make a unique value that stays the same between deployments.
  name: guid(adminPrincipalId, readerDefinitionId, subscription().id)
  properties: {
    principalType: 'Group'
    principalId: adminPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', readerDefinitionId)
  }
}

var rgScope = resourceGroup(newRg.name)

resource newRg 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: rgLocation
  tags: defaultTags
}

module configureRg './configureResourceGroup.bicep' = {
  name: 'configureRg'
  scope: rgScope
  params: {
    principalId: adminPrincipalId
    roleDefinitionId: logAnalyticsContributorDefinitionId
  }
}

module logAnalytics './createLogAnalytics.bicep' = {
  name: 'logAnalytics'
  scope: rgScope
  params: {
    logAnalyticsName: logAnalyticsName
    tags: defaultTags
  }
}

module keyValut './createKeyVault.bicep' = {
  name: 'keyvalut'
  scope: rgScope
  params: {
    keyVaultName: keyValutName
    tags: defaultTags
    logAnalyticsWorkspaceId: logAnalytics.outputs.logAnalyticsWorkspaceId
    diagSettingsName: keyValutDiagName
    accessPolicies: keyvaultAccessPolicies //see below for details, you can also do this using RBAC
  }
}

//see below 
//and https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults
var keyvaultAccessPolicies = concat(groupAccessPolicies, applicationAccessPolicies)

var groupAccessPolicies = empty(adminPrincipalId) ? [] : [
  {
    objectId: adminPrincipalId
    tenantId: subscription().tenantId
    permissions: {
      keys: [
        'get'
        'list'
        'update'
        'create'
        'import'
        'delete'
        'recover'
        'backup'
        'restore'
      ]
    }
  }
]

var applicationAccessPolicies = empty(applicationPrincipalId) ? [] : [
  {
    objectId: applicationPrincipalId
    tenantId: subscription().tenantId
    permissions: {
      keys: [
        'get'
        'list'
        'unwrapKey'
        'wrapKey'
      ]
    }
  }
]