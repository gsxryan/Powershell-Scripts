<#
RCautomate.com
script will detect code 38 driver errors, report to a error logfile.  If no Code 38 driver errors are detected, it will log the detection to a "Healthy" file
Between these two files, the information logging intent is to determine trends between healthy and unhealthy PCs to identify trends.
The centralized logpath must be writeable by the user or service that runs the script.
Code 38 is currently most seen with McAfee DLP / Citrix Receiver bug, reported from users as "USB Printer not working, or other approved USB Devices not working"
https://kc.mcafee.com/corporate/index?page=content&id=KB93017&actp=null&viewlocale=en_US&showDraft=false&platinum_status=false&locale=en_US
McAfee has since put guardrails around this information, I'm not sure if it's still available if you have an account.
#>

#Set the Logpath
$LogServer = "\\fileserver.contoso.com"
$LogPath = "Logs\Telemetry\DLP"

#Get the Extended version information from each application suspect to RCA
$CitrixVersion = (Get-ItemProperty "C:\Program Files (x86)\Citrix\ICA Client\Receiver\Receiver.exe" | Select-Object *).versioninfo.Fileversion
$DLPVersion = (Get-ItemProperty "C:\Program Files\McAfee\DLP\Agent\fcag.exe" | Select-Object *).versioninfo.Fileversion

#use two methods to detect user as one may occasionally fail
$User = [Environment]::UserName
$Computer = $env:COMPUTERNAME

#Gather details about the machine
$Model = (get-wmiobject Win32_ComputerSystem).model
$OS = Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT" -Name "CurrentVersion"

#Determine if the user is on-prem or not, use a IP range that matches your VPN or remote subnets
#In this example we use a 255.255.0.0
$VPN = ((Get-NetIPAddress).IPAddress | Where-Object {$_ -match ("^192[.]168[.].")}); if ($null -notmatch $VPN) {$VPN="VPN"} else {$VPN=""}

#Get Current Date and Time
$Date = Get-Date -Format d
$Time = Get-Date -Format T

#Check if any device has a Code 38 error
$Code38 = Get-WmiObject -Class Win32_PnpEntity -Namespace Root\CIMV2 | Where-Object {$_.ConfigManagerErrorCode -eq 38} | Select-Object SystemName, caption, DeviceID

#If it does, dump the info to a unique machine logfile for capturing errors,
#If it doesn't, dump to a shared logfile for healthy machines.
#Logfile output Date of Runfile, MachineName, MachineIP, Most Common user, caption, DeviceID, Model, OS Revision (22H2?)
If ($null -ne $Code38)
{
    foreach ($line in $code38)
        {
            $caption = $line.caption; $deviceID = $line.deviceID; $systemname = $line.SystemName
            Add-Content $LogServer\$LogPath\Code38Query$computer.log "$Date, $Time, $User, $systemname, $caption, $deviceID, $Model, $OS, DLP $DLPVersion, Citrix $CitrixVersion, $VPN"
        }
}
else {
    Add-Content $LogServer\$LogPath\Code38QueryHealthy.log "$Date, $Time, $User, $Model, $OS, DLP $DLPVersion, Citrix $CitrixVersion, $VPN, Healthy"
    }