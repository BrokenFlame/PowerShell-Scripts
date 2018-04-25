 <#
.Synopsis
   Sets the Microsoft SQL Server Default Backup Directory on SQL Server 2012 and later.
.DESCRIPTION
   Sets the Microsoft SQL Server Default Backup Directory on SQL Server 2012 and later. This function must be run from a computer which has the latest SQL Server SMO installed.
.EXAMPLE
  MsSqlDefaultBackupDirectory -Instance "(local)\MSSQLSERVER" -Path C:\Backups
.EXAMPLE
   "(local)\MSSQLSERVER" | MsSqlDefaultBackupDirectory -Path C:\Backups
#>
function Set-MsSqlDefaultBackupDirectory 
{
    [CmdletBinding()]
    [Alias()]
    Param(
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [string[]]$Instance = "(local)", 
    $Path
    )
    Begin
    {
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") 
    }
    Process
    {
        foreach($msInstance in $Instance)
        {
            $svr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$Instance";
            $svr.Properties["BackupDirectory"].Value = $Path
            $svr.Alter()
        }
    }
    End
    {
    }
} 
