
#powershell.exe -executionpolicy bypass "./SkypeAvailability.ps1 -path 'Z:\Powershell\List.csv'"
#NOTE: Must import CSV File with 2 Headers (Username, Hostname)

#Require the Path to CSV File
Param(
[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
[string]$Path)

#Imports CSV format columns, "Hostname, Username"
$List = Import-Csv $Path

#PING
foreach ($item in $List)
{
$Hostname = $item.Hostname
echo "Trying $Hostname"

#Ping each object
$Ping = (Test-Connection $Hostname -Count 1 -ErrorAction SilentlyContinue).ResponseTime

#Get AD object to verify it's Inactive or non existent
$AD = (get-adcomputer $Hostname).DistinguishedName

if ($AD -ne $null)
{
echo "$Hostname AD: $AD"
$AD = $null
}

if ($Ping -ne $null)
{
echo "$Hostname Online"
}
}