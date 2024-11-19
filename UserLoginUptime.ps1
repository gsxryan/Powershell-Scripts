# RCautomate.com
# Timecount - Count the time since first running the script
# Use when determining if a session logoff policy delay is effective

#Get current date time in UNIX seconds
$Starttime = Get-Date -Uformat %s

do {
    #count and display the current uptime
    $Realtime = Get-date -Uformat %s
    $Uptime = $Realtime - $Starttime
    $Uptime = [Math]::Round($Uptime)
    Write-Host "Seconds Uptime: $Uptime"
    sleep 5
}
while ($null -ne $Starttime)