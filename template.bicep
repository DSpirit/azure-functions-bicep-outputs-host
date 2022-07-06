param prefix string
param name string
param location string = resourceGroup().location

resource asp 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${prefix}-fn-asp-001'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Y1'
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${prefix}fnsasp001'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${prefix}-fn-asp-001'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource function 'Microsoft.Web/sites@2020-12-01' = {
  name: '${prefix}-fn-asp-001-${name}'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: asp.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsDashboard'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storage.listKeys().keys[0].value}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower('${prefix}-fn-asp-001-${name}')
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
    }
  }
}

output functionBaseUrl string = 'https://${function.properties.defaultHostName}/api'
