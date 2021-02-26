targetScope = 'resourceGroup'

param principalId string
param roleDefinitionId string

//lock the resouce group from getting accidentally deleted
resource lockResource 'Microsoft.Authorization/locks@2016-09-01' = {
  name: 'DontDelete'
  properties: {
    level: 'CanNotDelete'
    notes: 'Prevent deletion of the resourceGroup'
  }
}

//Assign role
resource assignmentResource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(principalId, roleDefinitionId, resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: principalId
  }
}