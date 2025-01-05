<#

Qiagen Ingenuity Pathway Analysis IPA, Local JNLP - Local JAR file management
version.txt is used as source control, so if software owners update, they can choose when to redistribute software
RCautomate.com 2018-2019

Utility:
Bypass IPA's QIASTART pre-start code (Blocked by some AV tools)
Detect Company default Java Installation
If it's standard - Download IPA JAR files and run with the Java.exe Environment Variable
If it's unsupported - Download IPA JAR files, Standardized JRE, and Launch from Portable folder

TASKS:
Improve Test-Path - Needs to test folder - to ONLY detect specific Java version
^Check for other versions installed that may override standard
When Windows 10 fully deployed / powershell modern deployed, use get-filehash to better manage
#>

#Define the JAR File prod path, and the Local Installation path
$User = [Environment]::UserName
If ($null -eq $User)
{$User = $env:USERNAME}

$AppServer = "\\appserver.contoso.com"
$LogServer = "\\logserver.contoso.com\logs\IPA"
$IPAFiles = "$AppServer\Java\IPA"
$InstallPath = "C:\Users\$User\Downloads\IPA_JNLP"

#Check if the Standard version is installed, change the version when company updates
$JavaExists = 1 #Test-Path 'C:\Program Files\Java\jre1.8.0_111\' IPA Will always run portable version
$PortableInstallExist = Test-Path "$InstallPath\start-IPA.bat"

function CopyPortableFiles
{
Write-Progress -Activity 'CopyPortableFiles' -Status "Copying Portable Files" -PercentComplete 30
   # Start-BitsTransfer -Source "$IPAFiles\jre1.8.0_111.zip" -Destination "$InstallPath" -DisplayName "JavaJRE" -TransferType Download -Priority High #-TransferPolicy Unrestricted
   # Start-BitsTransfer -Source "$IPAFiles\start-IPA-portable.bat" -Destination "$InstallPath" -DisplayName "PortableLauncher" -TransferType Download -Priority High #-TransferPolicy Unrestricted

Write-Progress -Activity 'CopyPortableFiles' -Status "Extracting Portable Files" -PercentComplete 40
    # extract the zip file to read contents
    # Write-Host "Extracting JRE Files"
    # Expand-Archive "$InstallPath\jre1.8.0_111.zip" "$InstallPath" -Force
    Copy-Item -Path $IPAFiles\version.txt -Destination $InstallPath #-Recurse

Write-Progress -Activity 'CopyPortableFiles' -Status "Cleanup" -PercentComplete 50
    #cleanup
    # Remove-Item “$InstallPath\jre1.8.0_111.zip”
Write-Progress -Activity 'CopyPortableFiles' -Status "Launching" -PercentComplete 100
}

Write-Progress -Activity 'LaunchIPA' -Status "Create Directory" -PercentComplete 10
#Create the folder if it doesn't exist
New-Item "$InstallPath" -ItemType Directory
Clear-Host

Write-Progress -Activity 'LaunchIPA' -Status "Verifying Version" -PercentComplete 20
Write-Host "Checking for latest IPA Files..."
#Compare the HashFiles to see if Program needs to be re-downloaded
$NetworkHash = Get-Content $IPAFiles\version.txt
$LocalHash = Get-Content $InstallPath\version.txt

#If it does match, just launch the application - first detecting if the user has java 1.8_111
If ($NetworkHash -eq $LocalHash)
{
    Write-Host "Hashes Match. Launching the Application Locally..."

If ($JavaExists -eq 1)
{
    Write-Host "Detected Standard Java Version, launching local"
    Start-Process "$InstallPath\start-IPA.bat"
}
else
{
    Write-Host "Detected Unmanaged Java Version, launching portable"
    If ($PortableInstallExist -eq 1)
{
    Start-Process "$InstallPath\start-IPA-portable.bat"
}
        else
        {

        Write-Host "Copying the Portable Files"
        CopyPortableFiles
        Start-Process "$InstallPath\start-IPA-portable.bat"
}}}
else
{
#If it doesn't match, or doesn't exist, copy the files
#cleanup currentdir if exists
Write-Progress -Activity 'DownloadIPA' -Status "Creating folders" -PercentComplete 20
Remove-Item "$InstallPath" -Recurse -Force
Write-Host "Copying Latest IPA files..."
Write-Progress -Activity 'DownloadIPA' -Status "Copying files" -PercentComplete 40
New-Item $InstallPath -ItemType Directory
Copy-Item -Path $IPAFiles\start-ipa.bat -Destination $InstallPath #-Recurse
New-Item $InstallPath\public -ItemType Directory
Copy-Item -Path $IPAFiles\version.txt -Destination $InstallPath
Clear-Host

#Show JAR file copy progress since it's so large
#BITS Hangs when AV is Scanning the JAR file.
Write-Progress -Activity 'DownloadIPA' -Status "Downloading IPA" -PercentComplete 60
Write-Host "AV Scanning Files..."
#Import-Module BitsTransfer
Start-BitsTransfer -Source "$IPAFiles\public\jars.zip" -Destination "$InstallPath\public\" -DisplayName "IPAjars" -TransferType Download -Priority High #-TransferPolicy Unrestricted
Write-Progress -Activity 'DownloadIPA' -Status "Extracting Files" -PercentComplete 80
Write-Host "Extracting JARS"
Expand-Archive "$InstallPath\public\jars.zip" "$InstallPath\public\" -Force

Write-Host "AV Scanning Files..."

Write-Progress -Activity 'DownloadIPA' -Status "Tidying up and Launching IPA..." -PercentComplete 100

#cleanup
Remove-Item “$InstallPath\public\jars.zip”

 If ($JavaExists -eq 1)
{
    Write-Host "Detected Standard Java Version, launching local"
    Start-Process "$InstallPath\start-IPA.bat"
}
else
{
    #If the Local Java Version has changed since last download grab the portable version
    CopyPortableFiles
    Write-Host "Detected Unmanaged Java Version, launching portable"
    Start-Process "$InstallPath\start-IPA-portable.bat"
}
}

#Log This Execution
#This does not mean it was launched successfully, just that it was attempted to launch

#Dynamically get the path executed - this does not need to be edited
<#
function Get-ScriptDirectory {
    Split-Path -parent $PSCommandPath
}

$PSCommandPath = $PSCommandPath.Replace("\\$AppServer\IPA", "")
$PSCommandPath = $PSCommandPath.Replace(".ps1", "")


#Get Current Date and Time
$Date = Get-Date -Format d
$Time = Get-Date -Format T

#write the logged data to Logfile#>
Add-Content $LogServer\IPA.log "$Date, $Time, $env:USERNAME, $env:COMPUTERNAME, IPA Bundle"
