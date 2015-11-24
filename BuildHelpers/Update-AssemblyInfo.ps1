<#
.Synopsis
   Updates the Assembly Version and File Version for MsBuild to version executables and dlls.
.DESCRIPTION
   Updates the assemblyInfo files for a C# application before MSBuild builds the binarys. 
.EXAMPLE
   Update-AssemblyInfo -Path C:\MyDirectory\AssemblyInfo.cs -Version 1.0.0.1
.EXAMPLE
   Update-AssemblyInfo -Path C:\MyDirectory -Version 1.0.0.1
#>
function Update-AssemblyInfo
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Path,
        [System.Version]$Version
    )

    Begin
    {
        $colAssemblyInfos = New-Object -TypeName System.Collections.ArrayList

        If(Test-Path -Path $Path)
        {
            if(Test-Path $Path -PathType Container)
            {
                Write-Debug "Searching for multiple AssemblyInfo.cs."
                $files = Get-ChildItem -Path $Path -Filter "AssemblyInfo.cs" -Recurse
                $colAssemblyInfos.AddRange($files)

            }
            else
            {
                Write-Debug "Searching for single file."
                $files = Get-Item -Path $Path
                $colAssemblyInfos.Add($file)                
            }
        }
        else
        {
            $notfoundex = New-Object -TypeName System.IO.FileNotFoundException -ArgumentList "$Path not found."
            throw $notfoundex
        }

        if($colAssemblyInfos.Count -le 0)
        {
            Write-Warning "Could not find any AssemblyInfo files."
        }


        $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $assemblyVersion = 'AssemblyVersion("' + $version + '")'
        $fileVersion = 'AssemblyFileVersion("' + $version + '")'
        
        
    }
    Process
    {
        foreach($file in $colAssemblyInfos)
        {
            Write-Host "Rewriting $($file.FullName)."
            $file.IsReadOnly = $false
            $content = Get-Content -Path $file.FullName -Encoding UTF8
            $content = [System.Text.RegularExpressions.Regex]::Replace($content, $assemblyVersionPattern, $assemblyVersion)
            $content = [System.Text.RegularExpressions.Regex]::Replace($content, $fileVersionPattern, $fileVersion)
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        }
    }
    End
    {
    }
}
