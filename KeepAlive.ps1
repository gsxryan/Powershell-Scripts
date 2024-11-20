<# RCAutomate.com
 Modified from Matthew Steeples
https://gist.github.com/MatthewSteeples/ce7114b4d3488fc49b6a

Toggle NUMLOCK to keepalive a remote RDP session for use when installing very long applications
 #>

 Clear-Host
 Write-Host "Keep-Alive with NUM Lock..."

 $WShell = new-object -com "Wscript.Shell"

 while ($true)
 {
    $WShell.sendkeys("{NUMLOCK}")
    Start-Sleep -Milliseconds 100
    $WShell.sendkeys("{NUMLOCK}")
    Start-Sleep -Seconds (Get-Random -Minimum 13 -Maximum 293)
 }