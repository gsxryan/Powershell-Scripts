<#Evaluate Non-Standard Software Installed on this machine.

#RCautomate.com

#Standard Image 1/1/2025 

Setup Step 1, On a baseline imaged PC model, run the following
(Get-WmiObject -Class Win32_Product).IdentifyingNumber
For each GUID identifier, add it to the script below.  The example is using Office 365

Step 2 is to run this script on a PC that is suspected to have software drift.
Software installation drift can cause various issues with the hardware, and identifying what is foreign is a great first step to find the culprit.

This is also useful when Migrating a users PC.  It can help identify forgotten requirements from the user.
This allows T2 to be proactive, mitigating future tickets as a result of PC refresh.
#>

$LogServer = "\\fileserver01.contoso.com"
$Table = $null

Write-Host "Getting Software list, please wait..."

$Table = Get-WmiObject -Class Win32_Product | where {$_.IdentifyingNumber -ne "{90160000-008F-0000-1000-0000000FF1CE}"`
-and $_.IdentifyingNumber -ne "{90160000-008C-0000-0000-0000000FF1CE}"`
-and $_.IdentifyingNumber -ne "{90160000-008C-0409-0000-0000000FF1CE}"`
-and $_.IdentifyingNumber -ne "{90160000-00DD-0000-1000-0000000FF1CE}"`
} | Format-Table -Property IdentifyingNumber,Name,Vendor -AutoSize | Out-String -Width 4096

$Table
    $Table | Out-File $LogServer\Logs\Migrations\$env:COMPUTERNAME.log

Start-Process "$env:windir\explorer.exe" -ArgumentList "$LogServer\Logs\Migrations\$env:COMPUTERNAME.log"