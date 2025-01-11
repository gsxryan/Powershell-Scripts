#RCautomate.com

#The following script can be used to determine the latest changes on a PC
#This is useful when performing RCA, determining what might have caused recent issues on machines reporting common issues.

$Table = (Get-WinEvent -FilterHashtable @{LogName="Application";ID=11707}) | Select UserID,TimeCreated,Message
$TableUpdates = ( Get-WinEvent -FilterHashTable @{ProviderName="Microsoft-Windows-WindowsUpdateClient"; ID=19} | Select TimeCreated, Message )

echo "SOFTWARE"
$Table

echo "UPDATES"
wmic qfe list
$TableUpdates

pause 

<#

#If the user performed the update is not SYSTEM or SCCM service account, lookup the AD User SID and define it.  
#This script is in development as an optimization to the above results.

If ($Table -ne $null)
{
$SID = Read-Host "Identify a Active Directory SID?"

Get-ADUser -identity '$SID'
}
#>