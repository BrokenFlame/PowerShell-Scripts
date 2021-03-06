<#
.Synopsis
   Set-DatabaseRecoveryModel sets the Database Recovery Model for Microsoft SQL Server Databases.
.DESCRIPTION
   Set-DatabaseRecoveryModel sets the Database Recovery Model for Microsoft SQL Server Databases. ALTER DATA require exclusive access to the database and thus, this call may appear to hang or time out if connections on the database are held open.  
.EXAMPLE
   Set-DatabaseRecoveryModel -Database "MyDatabase" -Server "MyServer" -RecoveryModel "Full"
.EXAMPLE
   Set-DatabaseRecoveryModel -Database "MyDatabase" -RecoveryModel "Simple"
.EXAMPLE
   "DatabaseName" | Set-DatabaseRecoveryModel -RecoveryModel "Simple"
#>
function Set-DatabaseRecoveryModel
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0, HelpMessage="The name of the database to change the recovery model on")]
        [ValidateNotNullOrEmpty()]
        [string]$Database,
        [string]$Server = "(local)",
        [ValidateNotNullOrEmpty()]
        [ValidateSet("BulkLogged","Full","Simple")]
        [string]$RecoveryModel
    )

    Begin
    {
        $errorCode = 0
        $DatabaseName = $Database
        $ServerName = $Server
        $newRecoveryModel = $null     
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO")

        if($RecoveryModel -eq "Full")
        {
            $newRecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Full
        }
        elseif($RecoveryModel -eq "Simple")
        {
            $newRecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::Simple
        }
        elseif($RecoveryModel -eq "BulkLogged")
        {
            $newRecoveryModel = [Microsoft.SqlServer.Management.Smo.RecoveryModel]::BulkLogged
        }
        else
        {
            Write-Error "Please select a valid Microsoft SQL Server Database Recovery Model."
        }
    }
    Process
    {
        try{
            $sqlServer = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $ServerName
            $currentRecoveryModel = $sqlServer.Databases["$DatabaseName"].RecoveryModel
            if($currentRecoveryModel -eq $newRecoveryModel)
            {
                Write-Verbose -Message "The recovery model for the database [$DatabaseName] is $($currentRecoveryModel.ToString())."
            }
            else
            { 
                Write-Verbose -Message "Setting the recovery model for the database [$DatabaseName] to Full."
                $sqlServer.Databases["$DatabaseName"].RecoveryModel = $newRecoveryModel
                $sqlServer.Databases["$DatabaseName"].Alter()
            }
        }
        catch
        {
            $errorCode = 1
            Write-Error $Error[0].ToString()
        }
    }
    End
    {
        $sqlServer = $null
        $currentRecoveryModel = $null
        $newRecoveryModel = $null
        $DatabaseName = $null
        return $errorCode
    }
}
