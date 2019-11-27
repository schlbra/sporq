function Get-SpqKeyVault {
    Param(
        [parameter(Mandatory = $true)] [string] $ApplicationCode,
        [parameter(Mandatory = $true)] [string] $EnvironmentName,
        [parameter(Mandatory = $true)] [string] $Location,
        [parameter(Mandatory = $false)] [string] $UniqueNamePhrase = $null,
        [parameter(Mandatory = $false)] [string] $ExceptionGuid,
        [parameter(Mandatory = $true)] [string] $LogAnalyticsResourceGroupName,
        [parameter(Mandatory = $true)] [string] $LogAnalyticsWorkspaceName
    )

    $keyVaultName = Get-SpqResourceName `
        -ApplicationCode $ApplicationCode `
        -EnvironmentName $EnvironmentName `
        -UniqueNamePhrase $UniqueNamePhrase `
        -ServiceTypeName "Microsoft.KeyVault/vaults" `
        -Location $Location
        
    $keyVaultDiagnosticsSettingName = $keyVaultName + "-diagsett"

    $json = '
    {
        "type": "Microsoft.KeyVault/vaults",
        "name": "' + $keyVaultName + '",
        "apiVersion": "2015-06-01",
        "location": "' + $Location + '",
        "properties": {
            "sku": {
                "family": "A",
                "name": "Standard"
            },
            "tenantId": "[subscription().tenantId]",
            "enabledForTemplateDeployment": "true",
            "accessPolicies": []
        },
        "resources": [            
            {
                "type": "providers/diagnosticSettings",
                "name": "Microsoft.Insights/' + $keyVaultDiagnosticsSettingName + '",
                "dependsOn": [
                    "[resourceId(''Microsoft.KeyVault/vaults'', ''' + $keyVaultName + ''')]"
                ],
                "apiVersion": "2017-05-01-preview",
                "properties": {
                    "name": "' + $keyVaultDiagnosticsSettingName + '",
                    "workspaceId": "[resourceId(''' + $LogAnalyticsResourceGroupName + ''', ''microsoft.operationalinsights/workspaces'', ''' + $LogAnalyticsWorkspaceName + ''')]",
                    "metrics": [
                        {
                            "category": "AllMetrics",
                            "enabled": true
                        }
                    ],      
                    "logs": [ 
                        {
                          "category": "AuditEvent",
                          "enabled": true
                        }
                    ]
                }
            }
        ]
    }
    '
    return ConvertFrom-Json $json
}







