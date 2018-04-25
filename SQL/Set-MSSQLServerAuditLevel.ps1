  <#
.Synopsis
   Sets the Microsoft SQL Server Login Audit Level for SQL Server 2012 and above.
.DESCRIPTION
   Sets the Microsoft SQL Server Login Audit Level for SQL Server 2012 and above. Please note that the SQL Server SMO must be installed on the computer executing this command.
.EXAMPLE
   Set-MsSqlServerLoginMode -Instance "(local)\MSSQLSERVER" -Mode Mixed
.EXAMPLE
   "(local)\MSSQLSERVER" | Set-MsSqlServerLoginMode -Mode Mixed
#> 
 function Set-MSSQLServerAuditLevel
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [string[]]$Instance = "(local)",
    [ValidateSet('None','All','Success', 'Failure')]
    $AuditLevel
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
            $svr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$msInstance";
            if($AuditLevel -eq "None")
            {
                $svr.Settings.AuditLevel = [Microsoft.SqlServer.Management.Smo.AuditLevel]::None
            }
            elseif($AuditLevel -eq "All")
            {
                $svr.Settings.AuditLevel = [Microsoft.SqlServer.Management.Smo.AuditLevel]::All
            }
            elseif($AuditLevel -eq "Success")
            {
                $svr.Settings.AuditLevel = [Microsoft.SqlServer.Management.Smo.AuditLevel]::Success
            }
            else
            {
                $svr.Settings.AuditLevel = [Microsoft.SqlServer.Management.Smo.AuditLevel]::Failure
            }
            $svr.Alter()
            Write-Host "The SQL Server Audit Level on $msInstance is $($svr.Settings.AuditLevel)"
            $svr = $null
        }
    }
    End
    { 
    }
}
 
