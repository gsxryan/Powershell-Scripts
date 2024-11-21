<# RCAutomate.com
Copy portable batch scripts to endpoints, and use PSEXEC to remotely install SCCM silently
Mitigates the need to RDP in to install
#>

$serverlist = "HOSTNAME1", "HOSTNAME2"

foreach ($server in $serverlist) {
    <# Is the server online/active?  Ping it, if not, stop. #>
$ping = (Test-Connection $server -Count 1 -ErrorAction SilentlyContinue).ResponseTime

If ($null -ne $ping)
{
#uninstall SCCM Client if it's installed
xcopy .\SCCMClient\* \\$server\C$\temp\ccm\*
.\PsExec.exe \\$server C:\temp\ccm\SCCMuninstall.bat

sleep 20 #give time to uninstall the client

#Install SCCM Client
.\PsExec.exe \\$server C:\temp\ccm\InstallSCCMPS2.bat

}
else {
    Write-Host "$server is OFFLINE!"
}
}