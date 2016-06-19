<#
.Synopsis
   Creates exchange for RabbitMQ 
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function New-RabbitMQExchange
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Name,
        [string]$Vhost,
        [ValidateSet('direct','fanout','headers','topic')]
        [string]$Type,
        [switch]$AutoDelete,
        [switch]$Durable,
        [switch]$Internal,
        [string]$Username,
        [string]$Password
    )

    Begin
    {
        if([System.String]::IsNullOrWhiteSpace($Vhost))
        {
            $Vhost = "%2F"
        }
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $uri = "$Server/api/exchanges"
        $exchangeUrl = "$Server/api/exchanges/$Vhost/$Name"

        $configuration = @{"type" = "$($Type.ToLower())"; "auto_delete" = "$($AutoDelete.ToString().ToLower())"; "durable" = "$($Durable.ToString().ToLower())"; "internal"= "$($Internal.ToString().ToLower())";} | ConvertTo-Json
    }
    Process
    {
        $exchange = Invoke-RestMethod -Method Get -Uri $uri -Credential $credential | Where { $_.name -eq $Name }
        If($exchange -eq $null)
        {
            Invoke-RestMethod -Method Put -Uri $exchangeUrl -Credential $credential -ContentType "application/json" -Body $configuration
        }
    }
    End
    {
    }
}


<#
.Synopsis
   Deletes exchange for RabbitMQ 
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Remove-RabbitMQExchange
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Name,
        [string]$Vhost,
        [ValidateSet('direct','fanout','headers','topic')]
        [string]$Type,
        [switch]$AutoDelete,
        [switch]$Durable,
        [switch]$Internal,
        [string]$Username,
        [string]$Password
    )

    Begin
    {
        if([System.String]::IsNullOrWhiteSpace($Vhost))
        {
            $Vhost = "%2F"
        }
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $uri = "$Server/api/exchanges"
        $exchangeUrl = "$Server/api/exchanges/$Vhost/$Name"

        $configuration = @{"type" = "$($Type.ToLower())"; "auto_delete" = "$($AutoDelete.ToString().ToLower())"; "durable" = "$($Durable.ToString().ToLower())"; "internal"= "$($Internal.ToString().ToLower())";} | ConvertTo-Json
    }
    Process
    {
        $exchange = Invoke-RestMethod -Method Get -Uri $uri -Credential $credential | Where { $_.name -eq $Name }
        If($exchange -ne $null)
        {
            Invoke-RestMethod -Method Delete -Uri $exchangeUrl -Credential $credential -ContentType "application/json" -Body $configuration
        }
    }
    End
    {
    }
}


function New-RabbitMQQueue
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Name,
        [string]$Vhost,
        [switch]$AutoDelete,
        [switch]$Durable,
        [ValidateNotNull()]
        [string]$Username,
        [ValidateNotNull()]
        [string]$Password
    )

    Begin
    {
        if([System.String]::IsNullOrWhiteSpace($Vhost))
        {
            $Vhost = "%2F"
        }
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $uri = "$Server/api/queues/$Vhost"
        $queueUrl = "$Server/api/queues/$Vhost/$Name"

        $configuration = @{"auto_delete"= "$($AutoDelete.ToString().ToLower())"; "durable" = "$($Durable.ToString().ToLower())"} | ConvertTo-Json
    }
    Process
    {
        $queue = Invoke-RestMethod -Method Get -Uri $uri -Credential $credential | Where { $_.name -eq $Name }
        If($queue -eq $null)
        {
            Invoke-RestMethod -Method Put -Uri $queueUrl -Credential $credential -ContentType "application/json" -Body $configuration
        }
    }
    End
    {
    }
}

function Remove-RabbitMQQueue
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Name,
        [string]$Vhost,
        [switch]$AutoDelete,
        [switch]$Durable,
        [ValidateNotNull()]
        [string]$Username,
        [ValidateNotNull()]
        [string]$Password
    )

    Begin
    {
        if([System.String]::IsNullOrWhiteSpace($Vhost))
        {
            $Vhost = "%2F"
        }
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $uri = "$Server/api/queues/$Vhost"
        $queueUrl = "$Server/api/queues/$Vhost/$Name"
    }
    Process
    {
        $queue = Invoke-RestMethod -Method Get -Uri $uri -Credential $credential | Where { $_.name -eq $Name }
        If($queue -ne $null)
        {
            Invoke-RestMethod -Method DELETE -Uri $queueUrl -Credential $credential
        }
    }
    End
    {
    }
}


function New-RabbitMQQueueBinding
{
    [CmdletBinding()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        $Server,
        [ValidateNotNull()]
        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$Exchange,
        [string]$Vhost="%2F",
        [string]$Queue,
        [string]$RoutingKey,
        [ValidateNotNull()]
        [string]$Username,
        [ValidateNotNull()]
        [string]$Password
    )

    Begin
    {
        if([System.String]::IsNullOrWhiteSpace($Vhost))
        {
            $Vhost = "%2F"
        }
        $securePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $Username, $securePassword

        $uri = "$Server/api/bindings"
        $bindingUrl = "$Server/api/bindings/$Vhost/e/$Exchange/q/$Queue"

        

        $configuration = @{} | ConvertTo-Json
        if([System.String]::IsNullOrWhiteSpace($RoutingKey))
        {
        $configuration = @{"routing_key"= "$($RoutingKey.ToString().ToLower())"} | ConvertTo-Json
        }
        
    }
    Process
    {
        $binding = Invoke-RestMethod -Method Get -Uri $uri -Credential $credential | Where { $_.source -eq $Exchange -and $_.destination -eq $Queue -and $_."destination_type" -eq "queue" -and $_.routing_key -eq $RoutingKey  }
        If($binding -eq $null)
        {
            Invoke-RestMethod -Method Post -Uri $bindingUrl -Credential $credential -ContentType "application/json" -Body $configuration
        }
    }
    End
    {
    }
}
