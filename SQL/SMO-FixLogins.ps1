[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "(local)"
$databases = $server.Databases |Where {$_.IsSystemObject -eq $false -and $_.IsAccessible -eq $true}
foreach($database in $databases)
{
    $orphandUsers = $database.Users | Where {$_.Login -eq ""-and $_.IsSystemObject -eq $false}
    if(!$orphandUsers)
    {
         Write-Verbose "The database [$database] has not got any orphand users."
    }
    else
    {
        foreach($user in $orphandUsers)
        {
            [string]$username = $user.Name
            $login = $server.Logins | Where {$_.Name -eq $username -and $_.isdisabled -eq $False -and $_.IsSystemObject -eq $False -and $_.IsLocked -eq $False}
            if($login -eq $null)
            {
                Write-Verbose "The username $username in database $database do not have an active login."
            }
            else
            {
                $query = "ALTER USER $username WITH LOGIN = $username;"
                Write-Verbose "Executing: $query"
                $server.Databases["$($database.Name)"].ExecuteNonQuery($query)
            }
        }
    }
}
$server, $databases, $database, $query, $username, $orphandUsers = $null
