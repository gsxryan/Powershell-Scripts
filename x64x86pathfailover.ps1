#RCAutomate.com
#Test ChromePath, use x64 by default if it exists, x86 as failover

$ChromeTest = Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"
if ($ChromeTest -eq $true) {$ChromePath ="C:\Program Files\Google\Chrome\Application\chrome.exe"}
else {$ChromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"}