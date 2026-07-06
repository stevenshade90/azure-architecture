# Phase 3: Implement Compute Resources

## Business Scenario
`Practice Company` needs Microsoft virtual machines deployed to department resource groups. There is also need for containers to host apps.  

## Step-by-Step Implementation
### Step 1: Automated Virtual Machine (Bicep)
`Practice Company` needs a Microsoft virtual machine deployed to the HR department. There are specific requirements for the VM: 
* The VM needs to be the `2022-datacenter-azure-edition` OS.
* A standard, basic model is suitable for the VM.

At some point, other departments will need this same VM deployed to their resource group. To ensure a consistent deployment, a `bicep` file was used to create the template for the VM. VS Code was used to create the Bicep file after installing the appropriate extensions. We will need the name of the VM, the admin username, and the password. Aside from the password, the values will be hardcoded.

```bicep
@description('Name of the VM specifically allocated to the HR department')
param vmName string = 'hr-vm-1-pc'

@description('The HR-specific username for the VM')
param adminUsername string = 'hr-user-vm'

@description('VM Password')
param adminPassword string
```
*Figure 1: The bicep file establishing the fundamental values: `vmName`, `adminUsername`, and `adminPassword`.*

The company only wants VMs to be deployed as `2022-datacenter-azure-edition`, and some other operating systems may be implemented in the future. An `@allowed` list is created to list the VMs that the company is willing to create. The required OS, `2022-datacenter-azure-edition`, is then assigned to the variable `OSVersion` to be used for reference later. The `Standard_D2s_v4` was selected to utilize a cost-effective, basic VM size.

```bicep
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
```
*Figure 2: Additional parameters are set for the VM to be deployed.*

A `networkConfig` variable was created to store variety of networking variables in clean syntax. Where appropriate, string interpolation is used for code maintainability and to reduce the risk of errors that may result from hardcoding the values. 

```bicep
var networkConfig = {
  nicName: '${vmName}-nic'
  subnetName: '${vmName}-subnet'
  virtualNetworkName: '${vmName}-vnet'
  networkSecurityGroupName: '${vmName}-nsg'
  addressPrefix: '10.0.0.0/16'
  subnetPrefix: '10.0.0.0/24'
}
```
*Figure 3: The `networkConfig` variable storing a variety of information that will be referenced later using dot syntax.*

Next, the NSG, VNet, and NIC were created for the VM. Dot syntax was frequently used to assign values to networking variables, such as in the NSG resource:

```bicep
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2022-05-01' = {
  name: networkConfig.networkSecurityGroupName
  location: location
}
```
*Figure 4: Dot syntax being utilized to assign values to a NSG variable.*

With all parameters and variables set, the VM can now be created.

```bicep

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
...
```
*Figure 5: A code segment that shows the creation of the VM.*

To deploy the VM, a PowerShell session was used to locate and execute the bicep file.

```powershell
Connect-AzAccount

New-AzResourceGroupDeployment `
  -ResourceGroupName "HR-Resource" `
  -TemplateFile "<file location>"
```
*Figure 6: The PS code to execute the bicep file.*

After the code executes, looking back into the HR-Resources resource group shows the VM, as well as the NSG, NIC, VNet, and disks.

![HR VM Image](./images/compute-vm-deployed-bicep.png)
*Figure 7: The VM and all other resources successfully deployed to the HR resource group.*

The bicep script used to deploy this VM can be found here: [main.bicep](./images/main.bicep)








