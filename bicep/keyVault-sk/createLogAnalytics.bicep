targetScope = 'resourceGroup'

param logAnalyticsName string
param location string = resourceGroup().location
param tags object = {}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: logAnalyticsName
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'Standard'
    }
  }
}

output logAnalyticsWorkspaceId string = logAnalytics.id