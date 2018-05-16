function Set-MsSqlDefaultDirectory
{
    [CmdletBinding()]
    [Alias()]
    Param(
    [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)]
    [string[]]$Instance = "(local)", 
    [Parameter(Mandatory=$true)]
    [string]$Path
    )

  Begin
  {
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") 
        [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended")
        $Path = $Path.TrimEnd("\")
   }
  Process
  {
    foreach($msInstance in $Instance)
    {
      $svr = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList "$msInstance";
      $svr.databases["TempDB"].LogFiles[0].Filename = $Path
      $svr.databases["TempDB"].LogFiles[0].Alter()
      $svr.databases["TempDB"].Alter()
      $svr = $null
    }
  }
end
{
}
