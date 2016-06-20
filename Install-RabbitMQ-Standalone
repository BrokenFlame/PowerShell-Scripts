Configuration RabbitMQServer
{
 param([string[]]$NodeName=“localhost“, [pscredential]$Credentials)

   
    Node $NodeName
    {

        Script ErlangDownload
        {
            GetScript = {
                $Result = (Test-Path -Path `"$Env:TEMP\otp_win64_18.3.exe`")
                @{GetScript = $GetScript; 
                    SetScript = $SetScript; 
                    TestScript = $TestScript; 
                    Result = $Result }
            }
            SetScript =  "(new-object System.Net.WebClient).Downloadfile(`"http://erlang.org/download/otp_win64_18.3.exe`", `"$Env:TEMP\otp_win64_18.3.exe`")"
            TestScript = "return (Test-Path -Path `"$Env:TEMP\otp_win64_18.3.exe`")"
        }

        Script RabbitMQServerDownload
        {
            GetScript = {
                $Result = (Test-Path -Path `"$Env:TEMP\rabbitmq-server-3.6.2.exe`")
                @{GetScript = $GetScript; 
                    SetScript = $SetScript; 
                    TestScript = $TestScript; 
                    Result = $Result }
            }
            SetScript =  "(new-object System.Net.WebClient).Downloadfile(`"https://www.rabbitmq.com/releases/rabbitmq-server/v3.6.2/rabbitmq-server-3.6.2.exe`", `"$Env:TEMP\rabbitmq-server-3.6.2.exe`")"
            TestScript = "return (Test-Path -Path `"$Env:TEMP\rabbitmq-server-3.6.2.exe`")"
        }

        Package Erlang
        {
        	Arguments = "/S"
            Ensure =“Present”  # You can also set Ensure to “Absent”
            Path  =“$Env:TEMP\otp_win64_18.3.exe”
            Name = “Erlang OTP 18 (7.3)”
            ProductId = “"
            DependsOn = “[Script]ErlangDownload”
        }

        Package RabbitMQServer
        {
            Arguments = "/S"
            Ensure =“Present”
            Path  =“$Env:TEMP\rabbitmq-server-3.6.2.exe”
            Name = “RabbitMQ Server 3.6.2”
            ProductId = “"
            DependsOn = @("[Script]RabbitMQServerDownload","[Package]Erlang")
        }
    }
}

RabbitMQServer
Start-DscConfiguration RabbitMQServer localhost -Wait -Force

# notes: Erlang needs sets the ERLANG_HOME system environment variable which requires a restart to take effect.
# Restart-Computer -Force
# CD "$env:ProgramFiles\RabbitMQ Server\rabbitmq_server-3.6.2\sbin"
# Invoke-Expression -Command "rabbitmq-plugins enable rabbitmq_management"
# Invoke-Expression -Command "rabbitmqctl restart"
