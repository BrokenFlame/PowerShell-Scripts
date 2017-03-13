[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$sqlSrv = New-Object 'Microsoft.SqlServer.Management.Smo.Server' "(local)"
	
$login = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Login -ArgumentList $sqlSrv, "DOMAIN\username"
$login.LoginType = "WindowsUser"

$login.AddToRole("sysadmin")
$login.Alter()
