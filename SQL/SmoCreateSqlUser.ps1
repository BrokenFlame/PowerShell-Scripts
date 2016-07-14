$sqlUsersAndPasswords = New-Object -TypeName System.Collections.Specialized.StringDictionary
$sqlUsersAndPasswords.Add("HackettResourceBundlesUser","1")
$sqlUsersAndPasswords.Add("FutureLoyaltyResourceBundlesUser", "2")
$sqlUsersAndPasswords.Add("FutureLoyaltyUser", "3")
$sqlUsersAndPasswords.Add("HackettUser", "4")

[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$server = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "(local)"
foreach($kvp in $sqlUsersAndPasswords)
{
   $login = $server.Logins | Where {$_.Name -eq $kvp.Key}
    if($login -eq $null)
    {
        $login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $server, $kvp.Key
        $login.LoginType = "SqlLogin"
        $login.PasswordExpirationEnabled = $false
        $login.PasswordPolicyEnforced = $false
        $login.Create($kvp.Value)
    }
}
$sqlUsersAndPasswords =$null
