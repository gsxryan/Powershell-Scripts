#RCautomate.com
#Stop, Disable Remote Services and confirm status

$servers = get-content "C:\temp\computerlist.txt"
foreach ($Server in $Servers)
{
write-host "Disabling print spooler on ", $Server 
Get-Service -Name Spooler -computername $Server | Stop-Service -Verbose
Set-Service -Name Spooler -StartupType Disabled -computername $Server

$PostStatus = (Get-Service -Name Spooler -computername $Server).status
$PostStart = (Get-Service -Name Spooler -computername $Server).starttype
write-host $Server $PostStatus $PostStart
}
