targetScope = 'resourceGroup'

param keyVaultName string
param location string = resourceGroup().location
param tags object = {}
param accessPolicies array = []
param diagSettingsName string = 'Save to LogAnalytics'
param logAnalyticsWorkspaceId string

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableSoftDelete: true
    enablePurgeProtection: true
    accessPolicies: accessPolicies
  }
}

resource diagnosticSettings 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: diagSettingsName
  scope: keyVault
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        enabled: true
        category: 'AuditEvent'
      }
    ]
    metrics: [
      {
        enabled: true
        category: 'AllMetrics'
      }
    ]
  }
}