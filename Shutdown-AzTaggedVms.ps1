workflow Shutdown-AzTaggedVMs
{
    #The name of the Automation Credential Asset this runbook will use to authenticate to Azure.
    $CredentialAssetName = 'DefaultAzureCredential'
    if($CredentialAssetName -eq $null)
    {
        Write-Error "Could not obtain CredentialAssetName, to perform the job."
    }

    #Get the credential with the above name from the Automation Asset store
    $Cred = Get-AutomationPSCredential -Name $CredentialAssetName
    if(!$Cred) {
        Throw "Could not find an Automation Credential Asset named '${CredentialAssetName}'. Make sure you have created one in this Automation Account."
    }
    else
    {
        Write-Output "Aquired PSCrentials."
    }

    #Connect to your Azure Account
    $Account = Add-AzureAccount -Credential $Cred
    if(!$Account) {
        Throw "Could not authenticate to Azure using the credential asset '${CredentialAssetName}'. Make sure the user name and password are correct."
    }
    else
    {
        Write-Output "Connected to Azure Account."
    }


    #This is where we actually do the task

    $VMsToShutdown = @()
    try 
    {
        $VMs = Get-AzVM
        foreach($vm in $VMs){
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
            Stop-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name -StayProvisioned -Force -ErrorAction Continue
            Write-Output "$($vm.Name) has been sent a shutdown signal."
        }
    }
}
