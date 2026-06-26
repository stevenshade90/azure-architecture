# Phase 2: Storage Infrastructure

## Business Scenario
`Practice Company` needs a storage infrastructure to hold a variety of company data. Storage needs to be cost-effective, secure, and shareable with other companies. 

## Step-by-Step Implementation
### Step 1: Automate Storage Account Creation 
To reduce production time, a PowerShell script was created to automate the creation of a storage account for each department. To meet company requirements, the location for the storage accounts was set to `EastUs` and `LRS` was used for data redundancy and cost-effectiveness:

```powershell
$Departments = @(
	[PSCustomObject]@{Department = "engineering"; ResourceGroup = "Engineering-Resources"},
	[PSCustomObject]@{Department = "finance"; ResourceGroup = "Finance-Resources"},
	[PSCustomObject]@{Department = "hr"; ResourceGroup = "HR-Resources"},
	[PSCustomObject]@{Department = "it"; ResourceGroup = "IT-Resources"}
)

Connect-AzAccount 

foreach ($Dept in $Departments)
{
	$StorageAccountParams = @{
		StorageAccountName = "$($Dept.Department)sa001pc"
		ResourceGroupName = $Dept.ResourceGroup
		Location = "EastUs"
		SkuName = "Standard_LRS"
	}
	New-AzStorageAccount @StorageAccountParams -AllowBlobPublicAccess $False
}
```
*Figure 1: A PowerShell script to automate the creation of storage accounts for each department in the company.*

Selecting **All Resources** will show that each storage account was created with the appropriate naming: 

![Storage Account Confirmation](./images/storage-all-storage-accounts.png)
*Figure 2: Image showing the successful creation of all storage accounts created by the PowerShell script.*
