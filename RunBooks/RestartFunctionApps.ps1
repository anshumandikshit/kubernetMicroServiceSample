#parameters
#checking source control
# adding keyvault checks
param (
    [string][Parameter(Mandatory=$false)]$ResourceGrpName='dev-rg' ,
    [string][Parameter(Mandatory=$false)]$KeyVaultName='sample-dev-kv',
    [string][Parameter(Mandatory=$false)]$KVKeyName='SubscriptionId'
)

Import-Module Az.Functions
Import-Module Az.keyVault
Import-Module Az.Resources

"Initialize jobs..."
$connectionName = "AzureRunAsConnection" 

try
{
    # Get the connection "AzureRunAsConnection "
    $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

    # "Logging in to Azure..."
    # Add-AzureRmAccount `
    #     -ServicePrincipal `
    #     -TenantId $servicePrincipalConnection.TenantId `
    #     -ApplicationId $servicePrincipalConnection.ApplicationId `
    #     -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
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
        $ErrorMessage = "Unable to connect Azure Account"
        throw $ErrorMessage
}

#Fetch subscriptionId from Key vault 
$Subscriptionsecret = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KVKeyName
$ssPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Subscriptionsecret.SecretValue)
try {
   $subscriptionId = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($ssPtr)
} finally {
   [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ssPtr)
}
Write-Output $subscriptionId

"finding Resources..."

$Resources = Get-AzResource -ResourceGroupName $ResourceGrpName | Where-Object {($_.ResourceName -like "*-fa") -and ($_.ResourceType -eq 'Microsoft.Web/sites')} | Select ResourceName, ResourceType
" Resources found"
foreach ($functionapp in $Resources)
{
    "foreach resource..."
    "restarting functionapps"
    Restart-AzFunctionApp -Name $functionapp.ResourceName -ResourceGroupName $ResourceGrpName -SubscriptionId $subscriptionId
    "functionapps named  restarted"
  #Write-Output ($functionapp.ResourceName + " of type " +  $functionapp.ResourceType)
}
