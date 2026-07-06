@description('Name of the VM specifically allocated to the HR department')
param vmName string = 'hr-vm-1-pc'

@description('The HR-specific username for the VM')
param adminUsername string = 'hr-user-vm'

@description('VM Password')
param adminPassword string


@description('Company only allows 2022 Microsoft VMs')
@allowed([
  '2022-datacenter-azure-edition'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('The size used for the VM')
param vmSize string = 'Standard_D2s_v4'

@description('Location pulled from RG entered during deployment')
param location string = resourceGroup().location

param securityType string = 'TrustedLaunch'

var networkConfig = {
  nicName: '${vmName}-nic'
  subnetName: '${vmName}-subnet'
  virtualNetworkName: '${vmName}-vnet'
  networkSecurityGroupName: '${vmName}-nsg'
  addressPrefix: '10.0.0.0/16'
  subnetPrefix: '10.0.0.0/24'
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkConfig.networkSecurityGroupName
  location: location
}


resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: networkConfig.virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        networkConfig.addressPrefix
      ]
    }
    subnets: [
      {
        name: networkConfig.subnetName
        properties: {
          addressPrefix: networkConfig.subnetPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: networkConfig.nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: resourceId('Microsoft.Network/virtualNetworks/subnets', networkConfig.virtualNetworkName, networkConfig.subnetName)
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    securityProfile: {
      securityType: securityType
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
      dataDisks: [
        {
          diskSizeGB: 1023
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
