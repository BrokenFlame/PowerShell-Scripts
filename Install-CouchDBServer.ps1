Configuration CouchDB
{
 param([string[]]$NodeName=“localhost“, [pscredential]$Credentials)

   
    Node $NodeName
    {

        Script CouchDBDownload
        {
            GetScript = {
                $Result = (Test-Path -Path `"$Env:TEMP\setup-couchdb-1.6.1_R16B02.exe`")
                @{GetScript = $GetScript; 
                    SetScript = $SetScript; 
                    TestScript = $TestScript; 
                    Result = $Result }
            }
            SetScript =  "(new-object System.Net.WebClient).Downloadfile(`"https://dl.bintray.com/apache/couchdb/win/1.6.1/setup-couchdb-1.6.1_R16B02.exe`", `"$Env:TEMP\setup-couchdb-1.6.1_R16B02.exe`")"
            TestScript = "return (Test-Path -Path `"$Env:TEMP\setup-couchdb-1.6.1_R16B02.exe`")"
        }

        Package CouchDB
        {
            Arguments = "/VERYSILENT /NORESTART"
            Ensure =“Present”
            Path  =“$Env:TEMP\setup-couchdb-1.6.1_R16B02.exe”
            Name = “Apache CouchDB 1.6.1”
            ProductId = “"
            DependsOn = "[Script]CouchDBDownload"
        }
    }
}

CouchDB
Start-DscConfiguration Couch -ComputerName localhost
