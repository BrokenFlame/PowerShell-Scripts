function Ensure-OcotopusProject
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [string]$Server,
        [string]$ApiKey = "API-DSFSOOHFTSYAWCSZNA5ISONQJK",
        [string]$Name,
        [string]$Description,
        [string]$ProjectGroup,
        [string]$LifecycleId = "",
        #[hash]$VersioningStrategy,
        #[hash]$ReleaseCreationStrategy = @{ "ReleaseCreationPackageStepId"=""; "ChannelId"= ""},
        #[string[]]$IncludedLibraryVariableSetIds = @(),
        [switch]$DefaultToSkipIdAlreadyInstalled,
        [switch]$AutoCreateRelease,
        [switch]$IsDisabled


    )

    Begin
    {
        $header = @{ "X-Octopus-ApiKey" = $ApiKey}
        $projectGroupCollectionUri = "$Server/api/projectgroups/all"
        $objectRestUri = "$Server/api/projects"
        $objectCollectionUri = "$Server/api/projects/all"

        #convertSwitches
        [bool]$bAutoCreateRelease = $AutoCreateRelease
        [bool]$bIsDisabled = $IsDisabled
        [bool]$bDefaultToSkipIdAlreadyInstalled = $bDefaultToSkipIdAlreadyInstalled
        $objProjectGroup = ((Invoke-RestMethod -Method Get $projectGroupCollectionUri -Headers $header) | Where {$_.Name -eq "$ProjectGroup"})
        if($objProjectGroup -eq $null)
        {
            Write-Error "ProjectGroup [$ProjectGroup] not found."
        }
        [string]$projectGroupId = $objProjectGroup.Id

    }
    Process
    {
        #Get information to configure object's RestAPI
        $objectRestSettings = Invoke-RestMethod -Method Get $objectRestUri -Headers $header

        Write-Debug -Message "$($objectRestSettings.ItemType)s per page = $($objectRestSettings.ItemsPerPage), totoal number of $($objectRestSettings.ItemType)s = $($objectRestSettings.TotalResults)"
        
        #if there are not any objects just create the one requested
        [bool]$objectExists = $false
        [string]$octopusObjecttId = ""
        
        if($($objectRestSettings.TotalResults) -gt 0)
        {

            Write-Debug -Message "Checking current $($objectRestSettings.ItemType)s list, to see if [$Name] already exists."

            $objectSet = ((Invoke-RestMethod -Method Get $objectCollectionUri -Headers $header) | Where {$_.Name -eq "$Name"})
            if($objectSet -ne $null)
            {
                    $objectExists = $true
                    $octopusObjecttId = $objectSet.Id
                    Write-Debug "Found the environment [$Name] using the Id [$octopusObjecttId]."
            }
        }


        #Build object variables
        $defaultLifeCycle = $null
        $defaultAutoCreateRelease = $null
        #If object does not exist and user did not provide value
        if ([System.String]::IsNullOrWhiteSpace($LifecycleId) -and (!($objectExists)))
        {
            $defaultLifeCycle = "Lifecycles-1"
        }
        #user provided value
        elseif((!([System.String]::IsNullOrWhiteSpace($LifecycleId))))
        {
            $defaultLifeCycle = $LifecycleId 
        }
        #object exist and user didn't provide value
        else
        {
            $defaultLifeCycle = $($objectSet.LifecycleId)
        }


        #$objObject = @{ "Name" = $Name;"Description" = $Description; "LifecycleId" = $LifecycleId; "VersioningStrategy" = $VersioningStrategy; "ReleaseCreationStrategy" = $ReleaseCreationStrategy; "IncludedLibraryVariableSetIds" = $IncludedLibraryVariableSetIds; "DefaultToSkipIdAlreadyInstalled" = $DefaultToSkipIdAlreadyInstalled ; "IsDisabled" = $IsDisabled } | ConvertTo-Json
        $objObject = @{ "Name" = $Name;"Description" = $Description; "LifecycleId" = $defaultLifeCycle; "DefaultToSkipIdAlreadyInstalled" = $bDefaultToSkipIdAlreadyInstalled ; "IsDisabled" = $bIsDisabled ; "AutoCreateRelease" = $bAutoCreateRelease ; "ProjectGroupId" = $projectGroupId } | ConvertTo-Json


        if($objectExists -eq $true)
        {
                Write-Debug -Message "Updaing the $($objectRestSettings.ItemType) [$Name]."
                Invoke-RestMethod -Method Put -Uri "$objectRestUri/$octopusObjecttId" -Headers $header -ContentType "application/json" -Body $objObject
        }
        else
        {
            Write-Debug -Message "Creating the $($objectRestSettings.ItemType) [$Name]."
            Invoke-RestMethod -Method Post -Uri $objectRestUri -Headers $header -ContentType "application/json" -Body $objObject
        }     
    }
    End
    {
    }
}

