function Install-NServiceBusHost
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Name,
        [string]$HomeDirectory,
        [switch]$isProduction
        
    )

    Begin
    {
        $productionString = " NServiceBus.Production"
    }
    Process
    {
        $thisService = Get-Service | Where { $_.Name -eq "$Name"}
        foreach($service in $thisService)
        {
            if(!($service.CanStop) -and (($service.status -ne "Stopped") -and ($service.status -ne "Stopping")))
            {
              Write-Error "Service cannot be stopped."
            }
            elseif($service.status -eq "Starting")
            {
              Sleep -Seconds 15
              $service.Stop()
            }
            elseif(($service.status -ne "Stopped") -and ($service.status -ne "Stopping"))
            {
            }
            elseif($service.CanStop)
            {
                $service.Stop()
            }

            do
            {
               Sleep -Seconds 5
            }
            while ($service.Status -ne "Stopped")

            [string]$servicePathName = Get-WmiObject -Class Win32_Service | Where {$_.Name -eq $service.Name} | select PathName
            $servicePath = $servicePathName.Remove(0,12).Split("`"")
            $servicePath
            [string]$literalServicePath = $servicePath[0]
            [string]$cmdUninstall = "$literalServicePath /uninstall /servicename:`"$Name`" NServiceBus.Production"
            
            if($isProduction)
            {
                $cmdUninstall = "$cmdUninstall $productionString"
            }

            Invoke-Expression -Command $cmdUninstall
        }



        #Create install string and execute service install
        $cmdInstall = "$HomeDirectory\NServiceBus.Host.exe /install /serviceName:`"$Name`""
        if($isProduction)
        {
            $cmdInstall = "$cmdInstall $productionString"
        }

        Push-Location -Path $HomeDirectory
            Invoke-Expression -Command $cmdInstall
        Pop-Location

        $newService = Get-Service | Where {$_.Name -eq "$Name" } 
        if(($newService.Status -ne "Starting") -and ($newService -ne "Running"))
        {
            $newService.Start()
        }
    }
    End
    {
    }
}
