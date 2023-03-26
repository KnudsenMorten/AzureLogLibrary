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

    $ResourceGroupDeployment   = "rg-azmon-datacollectionrules-p"
    $ResourceGroupDCR          = "rg-azmon-datacollectionrules-p"

    $ResourceGroupDCE          = "rg-azmon-datacollectionendpoints-p"

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

    # DCE
        Write-Output ""
        Write-Output "Validating Azure resource group exist [ $($ResourceGroupDCE) ]"
        try {
            Get-AzResourceGroup -Name $ResourceGroupDCE -ErrorAction Stop
        } catch {
            Write-Output ""
            Write-Output "Creating Azure resource group [ $($ResourceGroupDCE) ]"
            New-AzResourceGroup -Name $ResourceGroupDCE -Location $WorkspaceLocation
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
# dcr-windows-vmhealth-events-system_application
#######################################################################

    $DcrName                    = "dcr-windows-vmhealth-events-system_application"

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
# dcr-windows-vmhealth-events-security
#######################################################################

    $DcrName                    = "dcr-windows-vmhealth-events-security"

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
# dce-iis-logs-westeurope
#######################################################################

    $DceName                    = "dce-iis-logs-westeurope"

    $parameters = @{
        'Name'                  = $DceName + (Get-Random -Maximum 100000)
        'ResourceGroup'         = $ResourceGroupDCE
        'TemplateFile'          = ".\" + $DceName + ".json"
        'DceName'               = $DceName
        'DceResourceGroup'      = $ResourceGroupDCE
        'DceLocation'           = $WorkspaceLocation
        'PublicNetworkAccess'   = "Enabled"
        'Verbose'               = $true
    }

    New-AzResourceGroupDeployment  @parameters


#######################################################################
# dcr-windows-vmhealth-iis-logs-W3SVCx (1-50)
#######################################################################

    #-------------------------------
    # Getting DCE Resource Id
    #-------------------------------

        # Get DCEs from Azure Resource Graph
            $DCE_All = @()
            $pageSize = 1000
            $iteration = 0
            $searchParams = @{
                                Query = "Resources `
                                        | where type =~ 'microsoft.insights/datacollectionendpoints' "
                                First = $pageSize
                                }

            $results = do {
                $iteration += 1
                $pageResults = Search-AzGraph -UseTenantScope @searchParams
                $searchParams.Skip += $pageResults.Count
                $DCE_All += $pageResults
            } while ($pageResults.Count -eq $pageSize)

            # Error handling
                $DceInfo = $DCE_All | Where-Object { $_.name -eq $DceName }
                    If (!($DceInfo))
                        {
                            Write-Error "Could not find DCE with name [ $($DceName) ]"
                        }

        # DCE ResourceId (target for DCR ingestion)
        $DceResourceId  = $DceInfo.id
        $DceResourceId

    #-------------------------------
    # Deployment loop (1-15)
    #-------------------------------

    # initial
    $Number                             = 0

    Do
        {
            $Number                    += 1
            $DcrName                    = "dcr-windows-vmhealth-iis-logs-W3SVC" + $Number

            # deployment parameters
            $parameters = @{
                'Name'                  = $DcrName + (Get-Random -Maximum 100000)
                'ResourceGroup'         = $ResourceGroupDeployment
                'TemplateFile'          = $TemplatePath + "\" + "dcr-windows-vmhealth-iis-logs-W3SVCx" + ".json"
                'DcrName'               = $DcrName
                'DcrResourceGroup'      = $ResourceGroupDCR
                'WorkspaceLocation'     = $WorkspaceLocation
                'WorkspaceResourceId'   = $WorkspaceResourceId
                'DceEndpointId'         = $DceResourceId
                'iisLogDirectory'       = "C:\inetpub\logs\LogFiles\W3SVC" + $Number
                'Verbose'               = $true
            }

            New-AzResourceGroupDeployment  @parameters -AsJob
        }
    Until ($Number -ge 15)

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
