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

$subscriptionId =(Get-AzureKeyVaultSecret -VaultName '' -Name 'KeyName').SecretValueText
"finding Resources..."
$Resources = Find-AzureRmResource -ResourceGroupNameContains dev-rg | Where-Object {($_.ResourceName -like "*-fa") -and ($_.ResourceType -eq 'Microsoft.Web/sites')} | Select ResourceName, ResourceType
" Resources found"
foreach ($functionapp in $Resources)
{
    "foreach resource..."
    "restarting functionapps"
    Restart-AzFunctionApp -Name $functionapp.ResourceName -ResourceGroupName dev-rg -SubscriptionId $subscriptionId
    "restarted functionapps"
  #Write-Output ($functionapp.ResourceName + " of type " +  $functionapp.ResourceType)
}

