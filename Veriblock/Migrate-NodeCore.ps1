<#
Veriblock Update Script
Bounty 4002.2
Managed on Github Gist source:
https://gist.github.com/gsxryan/6da7fab06e038817a400cb09c0e6cdcf
Usage:
powershell.exe -executionpolicy bypass "./Migrate-Nodecore -oldpath 'C:\Old\Install\Folder' -newpath 'C:\New\Install\Folder'"}
Purpose:
Write a NodeCore migrations script (Windows)
Copies Nodecore wallet, popfiles, blockchain to latest version
Instead of migrating-we copy- rather than delete older sensitive data
Depends:
BITSadmin to transfer .zip file
Tested in Powershell 5.1, and emulated testing down to 3.x
Assumptions:
Assuming that format link: https://github.com/VeriBlock/nodecore-releases/releases/download/$LatestVersion/veriblock-nodecore-all-$LatestVersionCut.zip
will never change.
-release appended to latest nodecore folders
-nodecore-0* will have to be updated upon major version upgrade
DISCLAIMER:
While code has been tested in some envrionments, you are responsible for reviewing the code prior to execution and deciding yourself if it's safe to run.
IN NO EVENT SHALL VERIBLOCK OR SCRIPT DEV BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF VERIBLOCK OR DEVELOPER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
VERIBLOCK AND DEVELOPER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, PROVIDED HEREUNDER IS PROVIDED "AS IS". VERIBLOCK AND DEVELOPER HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
#>

#Require the Current Version Path, and the New Migration Path
Param(
[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
[string]$OldPath,
[Parameter(Mandatory=$true, ValueFromPipelineByPropertyName = $true)]
[string]$NewPath
)

<#
By Default Powershell uses SSL3, & TLS We are enabling TLS1.1 and TLS1.2 instead (more secure) for this SINGLE SESSION ONLY
GitHub only accepts Secure Crytography
SSL3 and TLS have been Deprecated due to POODLE CVE
If you reqire legacy setup for this session run the following commented code;
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls, ssl3"
#>

#Setting Powershell Security Protocol Settings (This session only)
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11"

#Get-JSON of VeriBlock Github releases API to determine latest version available
$releases = Invoke-RestMethod "https://api.github.com/repos/VeriBlock/nodecore-releases/releases"
#find the latest version # and populate zip
$LatestVersion = $releases[0].tag_name
$LatestVersioncut = $LatestVersion -replace 'v',''

#FUTURE FEATURE: (Automation for finding JSON asset path download link) Find the latest download path for .zip
#$LatestAssetList = $releases.[0].assets
#$LatestZipfileDownload = ($LatestAssetList).browser_download_url | Select-String zip

Write-Host "This process will migrate to" $LatestVersion
Write-Host "Press Enter to continue...Or CTRL+C to cancel..."
pause

#Make $NewPath if not created to copy new contents to
New-Item "$NewPath" -ItemType Directory

#downloading latest Nodecore
Clear-Host
Write-Host "Please wait while BITS transfers the latest nodecore zip file"
Import-Module BitsTransfer
#Start-BitsTransfer -Source "https://github.com/VeriBlock/nodecore-releases/releases/download/$LatestVersion/veriblock-nodecore-all-$LatestVersionCut-release.zip" -Destination "$NewPath" -DisplayName "NodeCoreUpgrade" -TransferType Download -Priority High #may be needed -TransferPolicy Unrestricted
bitsadmin /transfer NodecoreUpgrade /dynamic /download /priority FOREGROUND https://github.com/VeriBlock/nodecore-releases/releases/download/$LatestVersion/veriblock-nodecore-all-$LatestVersionCut.zip $NewPath\NodeCore.zip

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

Expand-ZIPFile -File "$NewPath\NodeCore.zip" -Destination "$NewPath"

#Cleanup Nodecore.zip
Remove-Item "$NewPath\NodeCore.zip"

#migrate oldfile properties
#NodeCore Testnet folder
Copy-Item "$OldPath\nodecore-0*\bin\testnet" -Destination "$NewPath\nodecore-$LatestVersionCut\bin\testnet" -Recurse

#PoP Miner State
Copy-Item "$OldPath\nodecore-pop-0*\bin\bitcoin-pop.wallet" -Destination "$NewPath\nodecore-pop-$LatestVersionCut\bin"
Copy-Item "$OldPath\nodecore-pop-0*\bin\bitcoin-pop-testnet.spvchain" -Destination "$NewPath\nodecore-pop-$LatestVersionCut\bin"
Copy-Item "$OldPath\nodecore-pop-0*\bin\bitcoin-pop-testnet.wallet" -Destination "$NewPath\nodecore-pop-$LatestVersionCut\bin"
Copy-Item "$OldPath\nodecore-pop-0*\bin\ncpop.properties" -Destination "$NewPath\nodecore-pop-$LatestVersionCut\bin"
Copy-Item "$OldPath\nodecore-pop-0*\bin\pop.state" -Destination "$NewPath\nodecore-pop-$LatestVersionCut\bin"

#PoW Miner Config
Copy-Item "$OldPath\nodecore-pow-0*\bin\nodecore_miner_pow.properties" -Destination "$NewPath\nodecore-pow-$LatestVersionCut\bin"

#FUTURE FEATURE: Ask if you'd like to migrate or use custom bootstrap link
#FUTURE FEATURE: Cleanup oldFolder Blockchain data.

#Kill java (Previous Nodecore instances)
Write-Host "Now Stopping existing java (nodecore)"
get-process -Name java | Stop-Process
Write-Host "Now Stopping CMD windows"
get-process -Name cmd | Stop-Process

Clear-Host
#Notice
Write-Host "Process is complete.  Please move nodecore.properties manually if needed (pool operators)"
Write-Host "This file may not be compatible with new version (peerlist), so review at your discretion"
Write-Host ""
Write-Host "Hit enter to continue launching the new Nodecore now, or CTRL+C to quit"
Pause

#start new nodecore
Start-Process "$NewPath\start.bat" -WindowStyle Maximized