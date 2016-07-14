$restoreData = New-Object -TypeName System.Collections.ArrayList
$MyDbData = New-Object -TypeName System.Management.Automation.PSObject
$MyDbData | Add-Member -MemberType NoteProperty -Name "Name" -Value "MyBB"
$MyDbData | Add-Member -MemberType NoteProperty -Name "DataDir" -Value $null
$MyDbData | Add-Member -MemberType NoteProperty -Name "LogDir" -Value $null
$MyDbData | Add-Member -MemberType NoteProperty -Name "Source" -Value ""
$MyDbData | Add-Member -MemberType NoteProperty -Name "Destination" -Value "C:\redist\mydb.bak"
$restoreData.Add($MyDbData)



[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "(local)";
$DefaultDataDir = $server.Settings.DefaultFile
$DefaultLogDir = $server.Settings.DefaultLog

foreach($restoreItemData in $restoreData)
{
    $restore = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Restore
    $restore.Devices.AddDevice($restoreItemData.Destination, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
    $logicalDataFiles = $restore.ReadFileList($server) | Where {$_.Type -eq "D"}
    $logicalLogFiles = $restore.ReadFileList($server) | Where {$_.Type -eq "L"}
    $logicalDbName = ($restore.ReadBackupHeader($server)).DatabaseName
    $logicalServerName = ($restore.ReadBackupHeader($server)).ServerName

    $restore.NoRecovery = $false
    $restore.ReplaceDatabase = $false
    $restore.Database = $restoreItemData.Name
    foreach($logicalDataFile in $logicalDataFiles)
    {
        if($restoreItemData.DataDir -eq $null)
        {
            Write-Host "Restoring Data to default path"
            $restore.RelocateFiles.Add((New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile -ArgumentList $logicalDataFile.LogicalName, "$($server.Settings.DefaultFile)\$($logicalDataFile.LogicalName).mdf"))
        }
        else
        {
            $restore.RelocateFiles.Add((New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile -ArgumentList $logicalDataFile.LogicalName, "$($restoreItemData.DataDir)\$($logicalDataFile.LogicalName).mdf"))
        }
    }
    foreach($logicalLogFile in $logicalLogFiles)
    
    {
        if($restoreItemData.LogDir -eq $null)
        {
            Write-Host "Restoring Logs to default path"
            $restore.RelocateFiles.Add((New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile -ArgumentList $logicalLogFile.LogicalName, "$($server.Settings.DefaultFile)\$($logicalLogFile.LogicalName).ldf"))
        }
        else
        {
            $restore.RelocateFiles.Add((New-Object -TypeName Microsoft.SqlServer.Management.Smo.RelocateFile -ArgumentList $logicalLogFile.LogicalName, "$($restoreItemData.LogDir)\$($logicalLogFile.LogicalName).ldf"))
        }
    }

$restore.SqlRestore($server)
$restore = $null
}
