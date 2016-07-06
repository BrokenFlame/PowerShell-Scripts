[string]$url = "https://download.octopusdeploy.com/octopus-tools/3.3.16/OctopusTools.3.3.16.zip"
[string]$TempLocation = "$($env:Windir)\Temp\OctopusTools.3.3.16.zip"
[string]$Destination = "$($env:Windir)"

if(!(Test-Path $TempLocation))
{
    $webclient = New-Object -TypeName System.Net.WebClient
    $webclient.DownloadFile($url, $TempLocation)
    #Unblock-File -Path "$($env:Windir)\Temp"
}
if(!(Test-Path "$Destination\Octo.exe")){
$objComPlus = New-Object -ComObject Shell.Application
$files = $objComPlus.Namespace($TempLocation).Items()
$objComPlus.Namespace($Destination).CopyHere($files)
}
