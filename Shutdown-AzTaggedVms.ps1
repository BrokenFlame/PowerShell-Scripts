# Ensures you do not inherit an AzureRMContext in your runbook
Disable-AzureRmContextAutosave –Scope Process

$connection = Get-AutomationConnection -Name AzureRunAsConnection

# Wrap authentication in retry logic for transient network failures
$logonAttempt = 0
while(!($connectionResult) -And ($logonAttempt -le 10))
{
    $LogonAttempt++
    # Logging in to Azure...
    $connectionResult =    Connect-AzureRmAccount `
                               -ServicePrincipal `
                               -Tenant $connection.TenantID `
                               -ApplicationID $connection.ApplicationID `
                               -CertificateThumbprint $connection.CertificateThumbprint

    Start-Sleep -Seconds 30
}

$AzureContext = Select-AzureRmSubscription -SubscriptionId $connection.SubscriptionID
$VMsToShutdown = @()
try 
{
    $VMs = Get-AzureRmVM
    foreach($vm in $VMs)
    {
        [System.Collections.Hashtable]$tags = $vm.Tags
        [ref]$parseResult = $false
            if($tags.ContainsKey("Shutdown") -and ([System.Boolean]::TryParse($tags["Shutdown"], $parseResult) -eq $true))
            {
                Write-Output "$($vm.Name) has been added to the shutdown list."
                $VMsToShutdown += $vm
            }
            if($parseResult -eq $false)
            {
                Write-Debug -Message "Unable to parse the value for the tag Shutdown on the VM [$($vm.Name)] in the resource group [$($vm.ResourceGroupName)]."
            }
    }
}
catch [System.Exception]
{
    Write-Error -Message "The following error occured: $($Error[0].ToString())"    
}
finally
{
    foreach($vm in $VMsToShutdown)
    {
        Stop-AzureRmVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -StayProvisioned -Force -ErrorAction Continue
        Write-Output "$($vm.Name) has been sent a shutdown signal."
    }
}
