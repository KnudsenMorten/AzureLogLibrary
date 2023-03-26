# Deployment of standard Data Collection Rules

<# PreReq
    install-module Az
    install-module Az.Graph
#>

#######################################################################
# Variables
#######################################################################

    $TenantId                  = "f0fa27a0-8e7c-4f63-9a77-ec94786b7c9e"
    $SubscriptionId            = "fce4f282-fcc6-43fb-94d8-bf1701b862c3"

    $WorkspaceResourceId       = "/subscriptions/fce4f282-fcc6-43fb-94d8-bf1701b862c3/resourcegroups/rg-logworkspaces/providers/microsoft.operationalinsights/workspaces/log-platform-management-srvnetworkcloud-p"
    $WorkspaceLocation         = "westeurope"

    $ResourceGroupDeployment   = "rg-azmon-datacollectionrules-t"
    $ResourceGroupDCR          = "rg-azmon-datacollectionrules-t"


#######################################################################
# Connectivitity to Azure
#######################################################################
    Disconnect-AzAccount -WarningAction SilentlyContinue
    Connect-AzAccount -tenant $TenantId -WarningAction SilentlyContinue

    $Context = Set-AzContext -Subscription $SubscriptionId -tenant $TenantId -WarningAction SilentlyContinue

#######################################################################
# Resource Group for DCRs
#######################################################################

    # DCR
        Write-Output ""
        Write-Output "Validating Azure resource group exist [ $($ResourceGroupDCR) ]"
        try {
            Get-AzResourceGroup -Name $ResourceGroupDCR -ErrorAction Stop
        } catch {
            Write-Output ""
            Write-Output "Creating Azure resource group [ $($ResourceGroupDCR) ]"
            New-AzResourceGroup -Name $ResourceGroupDCR -Location $WorkspaceLocation
        }

    # Deployment
        Write-Output ""
        Write-Output "Validating Azure resource group exist [ $($ResourceGroupDeployment) ]"
        try {
            Get-AzResourceGroup -Name $ResourceGroupDeployment -ErrorAction Stop
        } catch {
            Write-Output ""
            Write-Output "Creating Azure resource group [ $($ResourceGroupDeployment) ]"
            New-AzResourceGroup -Name $ResourceGroupDeployment -Location $WorkspaceLocation
        }


#######################################################################
# dcr-windows-vmhealth-performance_servicemap
#######################################################################

    $DcrName                    = "dcr-windows-vmhealth-performance_servicemap"

    $parameters = @{
        'Name'                  = $DcrName + (Get-Random -Maximum 100000)
        'ResourceGroup'         = $ResourceGroupDeployment
        'TemplateFile'          = ".\" + $DcrName + ".json"
        'DcrName'               = $DcrName
        'DcrResourceGroup'      = $ResourceGroupDCR
        'WorkspaceLocation'     = $WorkspaceLocation
        'WorkspaceResourceId'   = $WorkspaceResourceId
        'Verbose'               = $true
    }

    New-AzResourceGroupDeployment  @parameters


#######################################################################
# dcr-linux-vmhealth-performance_servicemap
#######################################################################

    $DcrName                    = "dcr-linux-vmhealth-performance_servicemap"

    $parameters = @{
        'Name'                  = $DcrName + (Get-Random -Maximum 100000)
        'ResourceGroup'         = $ResourceGroupDeployment
        'TemplateFile'          = ".\" + $DcrName + ".json"
        'DcrName'               = $DcrName
        'DcrResourceGroup'      = $ResourceGroupDCR
        'WorkspaceLocation'     = $WorkspaceLocation
        'WorkspaceResourceId'   = $WorkspaceResourceId
        'Verbose'               = $true
    }

    New-AzResourceGroupDeployment  @parameters


#######################################################################
# dcr-linux-vmhealth-performance_basic
#######################################################################

    $DcrName                    = "dcr-linux-vmhealth-performance_basic"

    $parameters = @{
        'Name'                  = $DcrName + (Get-Random -Maximum 100000)
        'ResourceGroup'         = $ResourceGroupDeployment
        'TemplateFile'          = ".\" + $DcrName + ".json"
        'DcrName'               = $DcrName
        'DcrResourceGroup'      = $ResourceGroupDCR
        'WorkspaceLocation'     = $WorkspaceLocation
        'WorkspaceResourceId'   = $WorkspaceResourceId
        'Verbose'               = $true
    }

    New-AzResourceGroupDeployment  @parameters


#--------------------------------------------------------------------------------------------------------------

# CLEANUP EXISTING DEPLOYMENTS
<#
    $ActiveDeployments = Get-AzResourceGroupDeployment -ResourceGroup $ResourceGroupDeployment
    $ActiveDeployments

    $CleanupDeployments  = $ActiveDeployments | Where-Object { $_.DeploymentName -like "*performance_serv*" }
    $CleanupDeployments | Remove-AzResourceGroupDeployment

    $CleanupDeployments  = $ActiveDeployments | Where-Object { $_.DeploymentName -like "*PerfAndMapDcr*" }
    $CleanupDeployments | Remove-AzResourceGroupDeployment

    $CleanupDeployments  = $ActiveDeployments | Where-Object { $_.DeploymentName -like "*NoMarketplace*" }
    $CleanupDeployments | Remove-AzResourceGroupDeployment

    $CleanupDeployments  = $ActiveDeployments | Where-Object { $_.DeploymentName -like "*VMI-DCR-Deployment*" }
    $CleanupDeployments | Remove-AzResourceGroupDeployment
     
    $CleanupDeployments  = $ActiveDeployments | Where-Object { $_.DeploymentName -like "*Microsoft.DataCollectionRules*" }
    $CleanupDeployments | Remove-AzResourceGroupDeployment

#>
