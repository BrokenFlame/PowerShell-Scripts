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
        [string]$Version,
        [string]$HomeDirectory,
        [switch]$isProduction
        
    )

    Begin
    {
        $productionString = " NServiceBus.Production"
    }
    Process
    {
        $thisService = Get-Service | Where { $_.Name -like "$Name%"}
        foreach($service in $thisService)
        {
            if(!($service.CanStop) -and ($service.status -ne "Stopped -or $service.status -ne "Stopping"))
            {
              Write-Error "Service cannot be stopped."
            }
            elseif($service.status -eq "Starting")
            {
              Sleep -Seconds 15
              $service.Stop()
            }
            else
            {
                $service.Stop()
            }

            do
            {
               Sleep -Seconds 5
            }
            while ($service.Status -ne "Stopped")

            [string]$servicePathName = Get-WmiObject -Class Win32_Service | Where {$_.Name -eq $service.Name} | select PathName
            $servicePath = $servicePathName.Split(" ")
            [string]$literalServicePath = $servicePath[0]
            [string]$cmdUninstall = "$literalServicePath /uninstall /servicename:`"$Name`" NServiceBus.Production"
            
            if($isProduction)
            {
                $cmdUninstall = "$cmdUninstall $productionString"
            }

            $oldHomeDir = Get-Item -Path $literalServicePath | Select DirectoryName
            Push-Location -Path $oldHomeDir
                Invoke-Expression -Command $cmdUninstall
            Pop-Location
            
            $oldHomeDir = [System.String]::Empty
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
    }
    End
    {
    }
}
