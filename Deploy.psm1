<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Publish-JSWebsite
{
    [CmdletBinding()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $SiteName,
        $ApplicationPath,
        $Version,
        $PackageName,
        [switch]$UseNuget
    )

    Begin
    {
        Write-Debug "Setting script variables."
        $applicationFullPath = Join-Path -Path $ApplicationPath -ChildPath $Version
        $acl = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "ReadAndExecute", "Allow")
        Write-Debug "Completed script variable assignment."

        Write-Debug "Checking prerequites"
        If(!(Test-Path -Path C:\DropBox -PathType Container))
        {
            Write-Error "Missing Drop Folder."
        }


        Write-Debug "Checked prerequites"
    }
    Process
    {

        if(!(Test-Path -Path $applicationFullPath -PathType Container))
        {
            New-Item -Path $applicationFullPath -ItemType Container
        }

        $dirApplicationPath = Get-Item -Path $applicationFullPath
        $aclApplicationPath = Get-Acl $dirApplicationPath
        $aclApplicationPath.AddAccessRule($acl)
        Set-Acl -Path $dirApplicationPath -AclObject $aclApplicationPath

        if($UseNuget)
        {
        }
        else
        {
            $packageFile = $PackageName + "." + $Version + ".nupkg"
            $packagePath = Join-Path -Path C:\DropBox -ChildPath $packageFile
            Write-Debug "Using package $packagePath."
            if(Test-Path -Path $packagePath)
            {
                Write-Debug "Creating Shell COM+ Object"
                $objComPlus = New-Object -ComObject Shell.Application
                $Path = $packagePath
                $Destination = $dirApplicationPath
                Write-Debug "Checking if the file $Path exists"
                If(!(Test-Path -LiteralPath $Path -PathType Leaf))
                {
                        Write-Error "The file $Path does not exists"
                        Return
                }
                Try
                {
                        Write-Debug "Checking if the destination path $Destination exists"
                        If(!(Test-Path -LiteralPath $Destination -PathType Container))
                        {
                                Write-Debug "The destination folder $Destination did not exists, attempting to create it."
                                New-Item -Path $Destination -ItemType Container
                        }

                        Write-Debug "Getting files to expand"
                        $files = $objComPlus.Namespace("$Path").Items()
                        Write-Verbose "Expanding files..."
                        $objComPlus.Namespace("$Destination").CopyHere($files)
                }
                Catch [Exception]
                {
                        Write-Error "An error occured while trying to extract $Path to $Destination"
                }

            }
            else
            {
                Write-Error "Cannot find $packagePath."
            }

        }

        $site = Get-Website | Where {$_.Name -EQ $SiteName}
        if($site -eq $Null)
        {
            New-Website -Name $SiteName -IPAddress "*" -PhysicalPath $applicationFullPath
        }
        else
        {
            Set-ItemProperty IIS:\Sites\$SiteName -Name physicalPath -Value $applicationFullPath
        }
    }
    End
    {
    }
}
