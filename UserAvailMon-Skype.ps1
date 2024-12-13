<# 

This was useful when Skype / Lync was available, and in transition to MS Teams.
This is likely not useful today, but snippets may be helpful to build something new.

Reports ICMP Ping + Skype User Availability, for use when identifying idle systems to RDP into to complete work.
Users that will commonly not callback for service calls can be monitored for activity.
When their machine is online, and inactive, we can login to complete our work without interrupting the user.

#After Each cycle, modify the imported CSV so it doesn't re-check completed entries

Usage:
powershell.exe -executionpolicy bypass "./SkypeAvailability.ps1 -path 'N:\Powershell\List.csv'"
NOTE: Must import CSV File with 2 Headers (Username, and Hostname)

#SKYPE AVAILABILITY reference
#Source: https://www.ravichaganti.com/blog/finding-lync-contact-availability-using-powershell/
#>

#Require the Path to CSV File
Param(
[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
[string]$Path)

#Import the Skype / Lync DLL
import-module "C:\Program Files (x86)\Realtek\Audio\Realtek Audio COM Components\Microsoft.Lync.Model.Dll"

#Imports CSV format columns, "Hostname, Username"
$List = Import-Csv $Path

echo "The following machines are inactive, delete them from the CSV when you've completed work"

#PING
foreach ($item in $List)
{
$Username = $item.Username
$Hostname = $item.Hostname

#Ping each object
$Ping = (Test-Connection $Hostname -Count 1 -ErrorAction SilentlyContinue).ResponseTime

#If object is online, check the Users Skype Status
if ($Ping)
{
#Convert Username NickName to EmailAddress
#Other applicable values: EmailAddress, mail or msRTCSIP-PrimaryUserAddress
$Email = (Get-ADUser $Username -Properties EmailAddress).EmailAddress

#Import Skype DLL
$client = [Microsoft.Lync.Model.LyncClient]::GetClient()

#Get User Email
$contact = $client.ContactManager.GetContactByUri("$Email")

#Check Availability Raw Value
#$contact.GetContactInformation("Availability")

#Status Key
#[enum]::GetValues([Microsoft.Lync.Model.ContactAvailability]) | %{ "{0,3} {1}" -f $([int]$_),$_ }

#Determine Availability status
$status = [Microsoft.Lync.Model.ContactAvailability] $contact.GetContactInformation("Availability")

if (($status -ne "Free") -and ($status -ne "Busy") -and ($status -ne "DoNotDisturb"))
{
echo "$hostname, $Username, $status"
}
}


}

#Ask for Completed Hostnames to delete from the CSV list
#Ask to Re-Ping list

#login to machine if user is: 
#NOT Free, Busy, DoNotDisturb [Add BusyIdle if problems occur with customers]

#OR
#None
#5000 FreeIdle, 7500 BusyIdle
#12500 TemporarilyAway, 15500 Away, or 18500 Offline
#OR #$Username = $null OR Unknown
