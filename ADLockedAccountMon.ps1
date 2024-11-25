# RCautomate.com
# Monitor domain for locked account

# Select the Domain account to monitor
$Accountname = "SERVICE_ACCT"
# Dynamically select the primary or nearest DC
$Domain = $env:LOGONSERVER

#loop infinitely
while ($n -lt 1)
{
    #Get the lock state on the specified user account above
$Locked = (Get-ADUser $Accountname -properties LockedOut).lockedout
$Date = Get-Date -Format "MM/dd/yyyy HH:mm"

#Print out the lock state.
if ($Locked -eq $true)
{Write-Host "$Date $Domain Locked"}
else
{Write-Host "$Date $Domain Unlocked"}

sleep 15
}