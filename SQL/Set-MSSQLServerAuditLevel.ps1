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
 
