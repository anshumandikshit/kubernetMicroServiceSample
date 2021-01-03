#parameters
#checking source control
param (
    [string][Parameter(Mandatory=$false)]$ResourceGrpName='dev-rg' ,
    [string][Parameter(Mandatory=$false)]$KeyVaultName='sample-dev-kv',
    [string][Parameter(Mandatory=$false)]$KVKeyName='SubscriptionId'
)

Import-Module Az.Functions

$connectionName = "AzureRunAsConnection" 

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    "Logging in to Azure..."
    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
}
catch {
    if (!$servicePrincipalConnection)
    {
        $ErrorMessage = "Connection $connectionName not found."
        throw $ErrorMessage
    } else{
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
}
try{
    #$Credential = Get-Credential
    Connect-AzAccount `
        -ServicePrincipal `
        -Tenant $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint
}

catch{
    if(!$Credential){
        $ErrorMessage = "Credential not found"
        throw $ErrorMessage
    }
    else{
        $ErrorMessage = "Unable to connect Azure Account"
        throw $ErrorMessage
    }
}

$subscriptionId =(Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $KVKeyName).SecretValueText
"finding Resources..."
$Resources = Find-AzureRmResource -ResourceGroupNameContains $ResourceGrpName | Where-Object {($_.ResourceName -like "*-fa") -and ($_.ResourceType -eq 'Microsoft.Web/sites')} | Select ResourceName, ResourceType
" Resources found"
foreach ($functionapp in $Resources)
{
    "foreach resource..."
    "restarting functionapps"
    Restart-AzFunctionApp -Name $functionapp.ResourceName -ResourceGroupName $ResourceGrpName -SubscriptionId $subscriptionId
    "restarted functionapps"
  #Write-Output ($functionapp.ResourceName + " of type " +  $functionapp.ResourceType)
}

