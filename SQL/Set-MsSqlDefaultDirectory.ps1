 <#
.Synopsis
   Sets the Microsoft SQL Server Default Directories on SQL Server 2012 and later.
.DESCRIPTION
   Sets the Microsoft SQL Server Default Directories on SQL Server 2012 and later. This function must be run from a computer which has the latest SQL Server SMO installed.
.EXAMPLE
  Set-MsSqlDefaultDirectory -Instance "(local)\MSSQLSERVER" -Type Backup -Path C:\Backups
.EXAMPLE
   "(local)\MSSQLSERVER" | Set-MsSqlDefaultDirectory -Type Backup -Path C:\Backups
#>
function Set-MsSqlDefaultDirectory
{
    [CmdletBinding()]
    [Alias()]
    Param(
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string[]]$Instance = "(local)", 
    [Parameter(Mandatory=$true)]
    [ValidateSet('Backup','File','Log')]
    [string]$Type,
    [string]$Path
    )

    Begin
    {
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") 
        $typeMapping = @{"File" = "DefaultFile"; "Log" = "DefaultLog"; "Backup" = "BackupDirectory"}
        $Path = $Path.TrimEnd("\")
    }
    Process
    {
        foreach($msInstance in $Instance)
        {
            $svr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$msInstance";
            $svr.Properties["$($typeMapping[$Type])"].Value = $Path
            Write-Warning "You must grant the SQL Server service account for $Instance access to the directory $Path"
            $svr.Alter()
            $svr.Refresh()
            [string]$currentPath = $svr.Properties["$($typeMapping[$Type])"].Value
            $currentPath = $currentPath.TrimEnd("\")
            if($currentPath -ne $Path)
            {
                Write-Warning "You must restart the SQL Server $instance for the new settings to take effect."
            }
            $svr = $null
        }
    }
    End
    {
    }
} 
