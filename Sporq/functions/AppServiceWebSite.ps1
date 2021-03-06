function Get-SpqAppServiceWebSite {
    Param(
        [parameter(Mandatory = $true)] [string] $ApplicationCode,
        [parameter(Mandatory = $true)] [string] $EnvironmentName,
        [parameter(Mandatory = $true)] [string] $Location,
        [parameter(Mandatory = $false)] [string] $UniqueNamePhrase = $null,
        [string] $ExceptionGuid,
        [parameter(Mandatory = $true)] [object] $AppServicePlan,
        [parameter(Mandatory = $false)] [bool] $IncludeManagedIdentity = $false
    )

    $webSiteName = Get-SpqResourceName `
        -ApplicationCode $ApplicationCode `
        -EnvironmentName $EnvironmentName `
        -UniqueNamePhrase $UniqueNamePhrase `
        -ServiceTypeName "Microsoft.Web/sites" `
        -Location $Location

    $json = '
    {
        "type": "Microsoft.Web/sites",
        "apiVersion": "2016-08-01",
        "name": "' + $webSiteName + '",
        "location": "' + $Location + '",
        "kind": "app",
        "properties": {
            "clientAffinityEnabled": true,
            "httpsOnly": true,
            "serverFarmId": "[resourceId(''Microsoft.Web/serverfarms'', ''' + $AppServicePlan.name + ''')]"
        },
        "dependsOn": [
            "[resourceId(''Microsoft.Web/serverfarms'', ''' + $AppServicePlan.name + ''')]"
        ],
        "resources": []'
    if ($IncludeManagedIdentity)
    {
        $json += ',
        "identity": {
            "type": "SystemAssigned"
        }'
    }
    
    $json += '}'
    return ConvertFrom-Json $json
}