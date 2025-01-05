<#

JAR Bundle - Copy from remote share to Local file management
Powershell: RCautomate.com

#>

#Define the JAR File prod path, and the Local Installation path
$Application = "ApplicationName"
$ApplicationJAR = "\\fileserver.contoso.com\Java\$Application"
$InstallPath = "C:\Users\$env:username\$Application"
$AvailRAM = [math]::Round(((Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory)/1mb,2)
$RecommendRAM = [math]::Round(($AvailRAM)-1)

Function LaunchJAR
{
Clear-Host

#Check Free RAM
Write-Host "Available RAM is: $AvailRAM GB.  MAXIMUM Recommended is $RecommendRAM GB."
Write-Host "NOTE:If <1GB, Install more RAM.  Never Exceed 31GB"
Write-Host "JAR may fail to launch if you exceed Maximum Available RAM"
Write-Host ""

$JavaRAM = Read-Host -Prompt "Enter #1-31 (or Press ENTER to use default, 4GB)"
 
If (!$JavaRAM)
{$JavaRAM=4
Write-Host "Launching JAR with 4 GB"}
else
{Write-Host "Launching JAR with $JavaRAM GB"}

 #Then launch the program
Start-Process -FilePath "$InstallPath/java/bin/java.exe" -ArgumentList "-Xmx$JavaRAM`G -jar $InstallPath\libs\Application.jar Application jdbc:oracle:thin:group/db@dbserver.contoso.com:1528:prod https://codeserver.contoso.com:8080/path/ c:\Temp https://uploadserver.contoso.com/pa/api/v2/dataupload JAR"
}

Write-Host "Checking for latest JAR Files..."
#Compare the HashFiles to see if Program needs to be re-downloaded
$NetworkHash = Get-Content $ApplicationJAR\libs\hash.txt
$LocalHash = Get-Content $InstallPath\libs\hash.txt

#If it does match, just launch the application
If ($NetworkHash -eq $LocalHash)
{
Write-Host "Hashes Match. Launching $Application Locally..."
LaunchJAR
}

else
{
#If it doesn't match, or doesn't exist, cleanup the old repository - and copy the files
Remove-Item "$InstallPath" -Recurse -Force
#Create the folder if it doesn't exist
New-Item "$InstallPath" -ItemType Directory
Clear-Host
Write-Host "Copying Latest $Application JAR file... This will take longer on VPN or WiFi!"
Write-Host "Downloading JAR (progress bar)..."
Write-Host "AV Scanning Files..."
Import-Module BitsTransfer
Start-BitsTransfer -Source "$ApplicationJAR\$Application.zip" -Destination "$InstallPath" -DisplayName "$Application" -TransferType Download -Priority High #-TransferPolicy Unrestricted
Write-Host "Unzipping Files..."

    # Unzip the zipfile
    Expand-Archive "$ApplicationJAR\$Application.zip" "$InstallPath" -Force

LaunchJAR

}

#Log This Execution
#This does not mean it was launched successfully, just that it was attempted to launch

#Get Current Date and Time
$Date = Get-Date -Format d
$Time = Get-Date -Format T

#write the logged data to Logfile
Add-Content \\logserver.contoso.com\Logs\JARBundles.log "$Date, $Time, $env:USERNAME, $env:COMPUTERNAME, $Application"