$configPath = (Get-Item -Path $webConfigPath).FullName
Write-Verbose "Ammending $configPath"
[xml]$xml = [xml](Get-Content -Path $configPath)

Write-Verbose "Current Config:"
$sw = New-Object System.Io.Stringwriter
$writer=New-Object System.Xml.XmlTextWriter($sw)
$writer.Formatting = [System.Xml.Formatting]::Indented
$xml.WriteContentTo($writer)
$sw.ToString()


if($xml.SelectSingleNode("//configuration//system.webServer") -eq $null)
{
    [System.Xml.XmlElement]$missingElement = $xml.CreateElement("system.web")
    $xml.SelectSingleNode("//configuration").AppendChild($missingElement)
}
$elementMachineKey = $xml.CreateElement("")
$elementMachineKey.SetAttribute("decryptionKey", "$decryptionKey")
$elementMachineKey.SetAttribute("validationKey", "$validationKey")
$xml.configuration["system.web"].AppendChild($elementMachineKey)
$xml.Save($configPath)

$sw = New-Object System.Io.Stringwriter
$writer=New-Object System.Xml.XmlTextWriter($sw)
$writer.Formatting = [System.Xml.Formatting]::Indented
$xml.WriteContentTo($writer)
$sw.ToString()
