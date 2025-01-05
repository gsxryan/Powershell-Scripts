<#

IPA, Automated User Desktop Installer - No admin permissions needed to install and launch.
The standard website installer requires an admin.  To avoid pressure on T2 for many manual installs, this script has been created.
This bypasses the need to run through change control board processes
As the application is now portable, users no longer have to request a new T2 ticket for every update (quarterly).

RCautomate.com 2021

Utility:
Install IPA's supported Desktop version that can autoupdate.
Installing in directories that user has access to. This will support qiastart auto-upgrades without an admin.
Must secure at least the Roaming directory to avoid unauthorized account use.

TASKS:
Tests: Shared PC folders, does it require a new installation per user? (yes, because users can save their login and qiagen hard code the roaming directory) 
    If so, does it have multiple installation listed in Ad/Rem Progs? (yes, but this would be OK)
    Dive logs to detect if configuration can be modified to launch without running the installer (yes)

#potential problem after an update?
#Delete or ignore C:\Users\$User\IPA\Roaming\analysis.ingenuity.com : ipa.vmoptions
#Old path C:\Users\$User\IPA\Roaming/IPA/analysis.ingenuity.com/cache

Alternate Installer from QIAGEN
# IPA.varfile - Example IPA installer response file
cacheLocation=C\:\\ipaExample\\alternateAppDataDir
sys.installationDir=C\:\\ipaExample\\alternateInstallDir

•	In the .varfile, specify custom values for the installer parameters.  These include the following parameters: 
o	sys.installationDir: The default installation directory
o	cacheLocation: The default application data directory
This file (attached) is an example: IPA_windows64_installer_v01-20-04.varfile
Note that characters in paths such as ":" and "\" need to be escaped with an "\"

Our installable package is built using a tool called install4j, and it does support a silent installation, which install4j refers to as “unattended mode.”  Install4j’s documentation for this is at:
https://www.ej-technologies.com/resources/install4j/help/doc/installers/installerModes.html
The default values for installation and application data directories can be specified using an install4j feature called “response files.”  Using this mechanism, the two defaults you mentioned can be set with the “cacheLocation” and “sys.installationDir” parameters.

Using Response Files:

- In the same directory as the IPA installer package, create a new file with the same name as the installer and the extension .varfile

- In the .varfile, specify custom values for the installer parameters.  These include the following parameters:
•	sys.installationDir: The default installation directory
•	cacheLocation: The default application data directory
The attached file IPA_windows64_installer_v01-20-04.varfile is an example 
Note that characters in paths such as ":" and "\" need to be escaped with a "\"

- When the qiastart installer is next run, the values in the .varfile will appear as defaults in the UI
 
More details on install4j response files are available at 
https://www.ej-technologies.com/resources/install4j/help/doc/installers/responseFile.html
    #>

#Define the JAR File prod path, and the Local Installation path
$User = [Environment]::UserName
If ($null -eq $User)
{$User = $env:USERNAME}

$AppServer = "\\appserver.contoso.com"
$IPAFiles = "$AppServer\IPA"
$InstallPath = "C:\Apps\IPA_$User" #Must be a user writeable directory DO NOT CHANGE without editing VMresponsefile options as well
$RoamingPath = "C:\Users\$User\IPA\Roaming\IPA" #Keep outside backup folder, Don't backup with onedrive, DO NOT CHANGE without editing VMresponsefile options as well
$RoamingRootPath = "C:\Users\$User\IPA" #use the root path for cleanup

#Check if the Standard company version is installed, change the version when company updates
$JavaExists = 1 #Test-Path 'C:\Program Files\Java\jre1.8.0_111\' IPA Will always run desktop installer
$IPAInstalled = Test-Path "$InstallPath\IPA.exe"

Write-Host "Checking for latest IPA Files..."
#Compare the HashFiles to see if Program needs to be re-downloaded
$NetworkHash = Get-Content $IPAFiles\version.txt
$LocalHash = Get-Content $InstallPath\version.txt

function CopyPortableFiles
{
#If it doesn't match, or doesn't exist, copy the files
#cleanup currentdir if exists

Write-Progress -Activity 'CopyPortableFiles' -Status "Creating folders" -PercentComplete 10
Remove-Item "$InstallPath" -Recurse -Force
Remove-Item "$RoamingRootPath" -Recurse -Force
Write-Host "Copying Latest IPA files..."
Write-Progress -Activity 'CopyPortableFiles' -Status "Copying files" -PercentComplete 20
New-Item $InstallPath -ItemType Directory
#Copy-Item -Path $IPAFiles\start-ipa.bat -Destination $InstallPath #-Recurse
#New-Item $InstallPath\public -ItemType Directory
Clear-Host

#Show ZIP file copy progress since it's so large
#BITS may hang when Security tools are Scanning the JAR file.

Write-Progress -Activity 'CopyPortableFiles' -Status "Copying IPA" -PercentComplete 30

Write-Host "Portable Files ~100MB, expect delays on VPN"
Write-Host "AV Scanning Files..."

Start-BitsTransfer -Source "$IPAFiles\IPAapps.zip" -Destination "$InstallPath" -DisplayName "IPAInstall" -TransferType Download -Priority High #-TransferPolicy Unrestricted
Start-BitsTransfer -Source "$IPAFiles\IPARoaming.zip" -Destination "$InstallPath" -DisplayName "IPARoaming" -TransferType Download -Priority High #-TransferPolicy Unrestricted

Write-Progress -Activity 'CopyPortableFiles' -Status "Extracting Portable Files" -PercentComplete 40
    # extract the zip file to read contents
    # Write-Host "Extracting JRE Files"
    Expand-Archive "$InstallPath\IPAapps.zip" "$InstallPath" -Force
    Expand-Archive "$InstallPath\IPARoaming.zip" "$RoamingPath" -Force
    Write-Host "AV Scanning Files..."

    Copy-Item -Path $IPAFiles\version.txt -Destination $InstallPath #-Recurse

Write-Progress -Activity 'CopyPortableFiles' -Status "UserSpecificSetup" -PercentComplete 60

    Write-Host "Creating Roaming response.varfile..."
    $responsefile = @(
    '# install4j response file for IPA 01-20-04'
    "cacheLocation=C\:\\Users\\$User\\IPA\\Roaming"
    'createDesktopLinkAction$Boolean=true'
    'executeLauncherAction$Boolean=true'
    'sys.adminRights$Boolean=false'
    "sys.installationDir=C\:\\Apps\\IPA_$User"
    'sys.languageId=en'
    'sys.programGroupAllUsers$Boolean=true'
    'sys.programGroupDisabled$Boolean=false'
    "sys.programGroupName=IPA $User`ii")
    $responsefile | ForEach-Object { Add-Content -Path  C:\Apps\IPA_$User\.install4j\response.varfile -Value $_ }
    
    Write-Host "Creating IPA.vmoptions file..."
    $vmoptions = @(
    "-classpath/a C:\Users\$User\IPA\Roaming/IPA/analysis.ingenuity.com/cache/appThird1.jar;C:\Users\$User\IPA\Roaming/IPA/analysis.ingenuity.com/cache/appThird2.jar;C:\Users\$User\IPA\Roaming/IPA/analysis.ingenuity.com/cache/commonThird.jar;C:\Users\$User\IPA\Roaming/IPA/analysis.ingenuity.com/cache/ipa.jar"
    '-Xmx4000m'
    '-Xms40m'
    '-Dsun.java2d.d3d=false'
    '-Dsun.java2d.noddraw=true')
    $vmoptions | ForEach-Object { Add-Content -Path  C:\Apps\IPA_$User\ipa.vmoptions -Value $_ }

Write-Progress -Activity 'CopyPortableFiles' -Status "Cleanup" -PercentComplete 80
Start-Sleep 5
#cleanup
    Remove-Item "$InstallPath\IPAapps.zip"
    Remove-Item "$InstallPath\IPARoaming.zip"

Write-Progress -Activity 'CopyPortableFiles' -Status "Launching" -PercentComplete 100
}

#If it does match, just launch the application - first detecting if the user has specific java version
If ($NetworkHash -eq $LocalHash)
{
    Write-Host "Hashes Match. Launching the Application Locally..."

    If ($JavaExists -eq 1)
    {
         Write-Host "Detected Standard Java Version, launching local"
         Start-Process "$InstallPath\IPA.exe"
    }
        else
        {
            Write-Host "Detected Unmanaged Java Version, launching portable"
                If ($IPAInstalled -eq 1)
                    {
                        Start-Process "$InstallPath\IPA.exe"
                    }
                else
                    {
                        #Hashes match but java is not installed (obsolete)
                        Write-Host "Copying the Portable Files"
                        CopyPortableFiles
                        Start-Process "$InstallPath\IPA.exe"
                    }}}
else
    {
    #Hashes Don't match
    CopyPortableFiles

        If ($JavaExists -eq 1)
            {
                Write-Host "Detected Standard Java Version, launching local"
                Start-Process "$InstallPath\IPA.exe"
            }
        else
            {
                #If the Local Java Version has changed since last download grab the portable version (obsolete)
                CopyPortableFiles
                Write-Host "Detected Unmanaged Java Version, launching portable"
                Start-Process "$InstallPath\IPA.exe"
            }
    }