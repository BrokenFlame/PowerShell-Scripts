 <#
.Synopsis
   Sets the Microsoft SQL Server Login mode for SQL Server 2012 and above.
.DESCRIPTION
   Sets the Microsoft SQL Server Login mode for SQL Server 2012 and above.
.EXAMPLE
   Set-MsSqlServerLoginMode -Instance "(local)\MSSQLSERVER" -Mode Mixed
.EXAMPLE
   "(local)\MSSQLSERVER" | Set-MsSqlServerLoginMode -Mode Mixed
#>
function Set-MsSqlServerLoginMode
{    
    (
    [CmdletBinding()]
    [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
    [string[]]$Instance = "(local)",
    [ValidateSet('Mixed','Integrated','Normal')]
    $Mode
    )

    BEGIN
    {
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") 
    }
    PROCESS
    {
        foreach($msInstance in $Instance)
        {
            $svr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$msInstance";
            if($Mode)
            {
                $svr.Settings.LoginMode = [Microsoft.SqlServer.Management.Smo.ServerLoginMode]::Normal
            }
            if($Mode -eq "Mixed")
            {
                $svr.Settings.LoginMode = [Microsoft.SqlServer.Management.Smo.ServerLoginMode]::Mixed
            }
            else
            {
                $svr.Settings.LoginMode = [Microsoft.SqlServer.Management.SMO.ServerLoginMode]::Integrated
            }
            $svr.Refresh()
            Write-Host "$msInstance Login Mode is $($srv.Settings.LoginMode)"
            $svr = $null
        }
    }
    END
    { 
    }
}

 
