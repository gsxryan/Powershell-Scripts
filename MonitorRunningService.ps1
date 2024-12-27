$CPUtil = (Get-Process -ProcessName notepad).cpu

if (!$CPUtil) {Write-Host "Notepad is not running"}

else {Write-Host "Notepad is running"}