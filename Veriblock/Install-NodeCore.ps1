<#
Veriblock Install Script
Veriblock Telegram KernelPanick
Managed on Github gist https://gist.github.com/gsxryan/20795e55d1e8ef079e42062656cc7eea
Usage:
powershell.exe -executionpolicy bypass "./Install-NodeCore.ps1"}
Purpose:
Write a NodeCore Installation Script (windows)
Copies and installs latest Nodecore suite, and bootstrap blockchain
Assumptions:
-No NodeCore folder exists where you run the script from.
-You cannot install at the root of a directory (Ex: C:\)
-Java is currently a manual installation due to it's many potential incompatibilites with other dependent software that may be on your machine.
You are responsible for verifying compatibility with Java 1.8 x64.  We will direct you to the download page if needed.
DISCLAIMER:
While code has been tested in some envrionments, you are responsible for reviewing the code prior to execution and deciding yourself if it's acceptable to run.
IN NO EVENT SHALL VERIBLOCK OR SCRIPT DEV BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF VERIBLOCK OR DEVELOPER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
VERIBLOCK AND DEVELOPER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, PROVIDED HEREUNDER IS PROVIDED "AS IS". VERIBLOCK AND DEVELOPER HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#>

# EVALUATE: NodeCore Requirements

$CurrentDir = get-location

Write-Host "This Script assumes you'd like to install Nodecore to the current Path"
Write-Host "Move this file to the directory you'd like to install to"
Write-Host "$CurrentDir\NodeCore"
Write-Host "Press CTRL+C to stop or,"
pause

Write-Host "Checking to see if your system meets the minimum requirements for NodeCore to run..."

    $RAMAvailable = (Get-Counter -Counter "\Memory\Available MBytes").CounterSamples[0].CookedValue
    If ($RAMAvailable -lt 4)
    {Write-Host "This system needs at least 4GB of RAM for NodeCore to run.  Exiting Install..."
    pause
    exit}

    $LogicalProcessors = (Get-WmiObject Win32_processor).NumberOfLogicalProcessors
    If ($LogicalProcessors -lt 2)
    {Write-Host "This system needs at least 2 cores for NodeCore to run.  Exiting Install..."
    pause
    exit}
 
    $CurrentDriveLetter = (Get-location).Drive.Name
    
    $TotalDiskSpace = (Get-WmiObject win32_logicaldisk -Filter "DeviceID='$CurrentDriveLetter`:'").Size /1GB
    If ($TotalDiskSpace -lt 50)
    {Write-Host "This system needs at least 50GB total disk space for NodeCore to run.  Exiting Install..."
    pause
    exit}
 
    $FreeDiskSpace = (Get-WmiObject win32_logicaldisk -Filter "DeviceID='$CurrentDriveLetter`:'").FreeSpace /1GB
    If ($FreeDiskSpace -lt 15)
    {Write-Host "This system needs at least 15GB free disk space for NodeCore to run.  Exiting Install..."
    pause
    exit}
 
    Write-Host "Your system is suitable, continuing installation of NodeCore..."

#EVALUATE:JAVA
Write-Host "Checking to see if you need Java ..."

$JavaVersion = @(Get-CimInstance -ClassName Win32_Product) -like '*Java*8*64*'
If (!$JavaVersion)
    {Write-Host "You must have Java 8 64-bit installed.  Rerun after installing Java 8 64-bit."
    Start-Process "https://www.java.com/en/download/win10.jsp"
    pause
    exit
    }

    Write-Host "You have Java 8 64-bit, continuing installation of NodeCore..."


# Placeholder for installing Other Dependencies:
#
# Windows Contains all dependencies currently.


# Get url for latest nodecore version

$releases = Invoke-RestMethod "https://testnet.explore.veriblock.org/api/stats/download"

$latestNodecore = $releases.nodecore_all_zip
$NCVersion = $latestNodecore | Select-String '(?<=veriblock-nodecore-all-)[\d{1,}.\d{1,}.\d{1}]*' | ForEach-Object { $_.Matches[0].Value }
$NCVersionTrim = $NCVersion -replace ".$"
$latestBootStrap = $releases.bootstrapfile_zip
$bootstrapCheckSum = $releases.bootstrapfile_zip_checksum

#Make NodeCore Folder if not created, to copy new contents to
New-Item "$CurrentDir\NodeCore" -ItemType Directory

# Download latest version of nodecore & bootstrap
Invoke-Item "$CurrentDir\NodeCore"
Import-Module BitsTransfer
#GitHub forwards https download links to Amazon S3 which breaks the Start-Bitstransfer cmdlet, so we fallback to bitsadmin
Write-Host "Starting NodeCore download..."
bitsadmin /transfer NodecoreInstall /dynamic /download /priority FOREGROUND "$latestNodecore" "$CurrentDir\NodeCore\NodeCore.zip"
Write-Host "Starting Bootstrap download, this will take awhile... Use task manager to watch network transfer"
Start-BitsTransfer -Source "$latestBootStrap" -Destination "$CurrentDir\NodeCore\BootStrap.zip" -DisplayName "BootStrapDownload" -TransferType Download -Priority High #may be needed -TransferPolicy Unrestricted

#verify filehash
$BootstrapHash = (Get-FileHash $CurrentDir\NodeCore\BootStrap.zip -Algorithm MD5).Hash

if ($bootstrapCheckSum -ne $BootstrapHash)
{Write-Host "The Checksum does not match VBK API.  VBK should update checksum, or you should rerun this installer"
pause
exit}

#get zipfile, extract, cleanup downloaded zip
        function Expand-ZIPFile($file, $destination)
   {
        $shell = new-object -com shell.application
        $zip = $shell.NameSpace($file)
        foreach($item in $zip.items())
    {
        $shell.Namespace($destination).copyhere($item)
    }
    }

Write-Host "Extracting NodeCore"
Expand-ZIPFile -File "$CurrentDir\Nodecore\NodeCore.zip" -Destination "$CurrentDir\NodeCore"

Write-Host "Extracting Bootstrap for fast blockchain sync"
New-Item "$CurrentDir\NodeCore\nodecore-$NCVersionTrim\bin\TestNet" -ItemType Directory
Expand-ZIPFile -File "$CurrentDir\NodeCore\BootStrap.zip" -Destination "$CurrentDir\NodeCore\nodecore-$NCVersionTrim\bin\TestNet"

#Cleanup zipfiles
Write-Host "Cleaning Up Zipfiles"
Remove-Item "$CurrentDir\NodeCore\NodeCore.zip"
Remove-Item "$CurrentDir\NodeCore\BootStrap.zip"
$NodeCoreDir = "$CurrentDir\NodeCore"
Get-ChildItem "$NodeCoreDir" -Include *.tmp -Recurse | ForEach ($_) { Remove-Item $_.Fullname }
del "$NodeCoreDir\*.tmp"

#start Nodecore
Start-Process "$CurrentDir\NodeCore\start.bat" -WindowStyle Maximized