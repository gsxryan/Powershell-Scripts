<# RCautomate.com - SAS Install ZIP/BITS Method
Wrapping Vendor's Install script which runs the cached installer

This could be utilized for other large installers for other applications.
BITS must be run as normal user (non admin) to avoid internet being blocked by some strict environments that block admin account internet access.  
Technicians should instruct users to double click this ahead of time to prepare for technician install scheduling

2nd stage requires admin to install the cached files
Attempt to stabilize and greatly increase Admin Experience and performance of remote installs for SAS using distant fileshare ~12GB
#>

<# ADMIN INSTALL INSTRUCTIONS
1)	Have the requestor (or assist them to) run the following script to Download the install files.  Once completed it will tell them to reach out to the admin to complete the installation.
      a.	\\fileshare.contoso.com\SAS94x64 [InstallSAS-ZIPPED-User.bat]
2)	Once they reach out to you, login as your admin account or elevate the following script as administrator
      a.	\\fileshare.contoso.com\SAS94x64 [InstallSAS-ZIPPED-ADMIN.bat]
      b.	Follow the standard SAS prompts
      c.	Follow the powershell prompts if it launches SAS successfully, it will cleanup the installation directory
#>

<# Remote site repo notes:
Remote sites with fileservers will have to make sure their ZIP file stays synced with Main.  If you have permissions to update the fileshare's path you can run this script to verify it is still OK.:
 [SyncMaintoRemoteShare.ps1] – run with powershell
#>

#Environment Variables
$InstallPath = "C:\temp\sas"
$ZIPName = "SAS_9_4_M7.zip"
$ZIPPath = "\\MAINfileshare.contoso.com\SAS\$ZIPName"
$REMOTEPath = "\\REMOTEfileshare.contoso.com\SAS94x64\$ZIPName"
$LogPath = "\\logserver.contoso.com\Telemetry\SAS" #must be WRITEable to users
$Machine = $env:COMPUTERNAME
$VPNrange = "^10[.]10[.]."
$Remote = "RM" #Remote Hostname prefix

#gather telemetry
$User = [Environment]::UserName
#Get Current Date and Time for started session
$Date = Get-Date -Format d
$Time = Get-Date -Format T
$BenchmarkStart = Get-Date -Uformat %s
$VPN = ((Get-NetIPAddress).IPAddress | Where-Object {$_ -match ("$VPNrange")}); if ($null -notmatch $VPN) {$VPN=", VPN"} else {$VPN=$Null}

<# Pick closest source to user
if machine is NOT on VPN, contains Remote site hostname, and the Remote source matches Main Fileshare, download from Remote fileshare instead (faster)
If the remote Source doesn't match - notify that an field admin needs to update the fileshare and fallback to using Main's fileshare

ZIP file performance testing
Main Fileshare to Remote site seems capped at 16Mbps (Approx 2 Hrs)
Main Fileshare to VPN seems capped to Central USA to 3Mbps (Approx 11.3 Hrs)
Remote Fileshare to On-site has pushed up to 900Mbps (Approx 1.5 Mins) - Probably similar for Main Fileshare and Main On-site users.
Conclusion: In some instances we can save Technicians a full day of install time (8-11 hours)#>

#Is this machine remote site and not on VPN?
If (($null -eq $VPN) -and ($Machine -match "$Remote"))
{
$REMOTEHash = (Get-Item $REMOTEPath).Length/1KB
$sourceHash = (Get-Item $ZIPPath).Length/1KB

#Remote Fileshare matches Main?, then change the install Source to Remote site
If (($REMOTEHash -eq $sourceHash) -and ($null -ne $REMOTEHash))
{ $ZIPPath = "$REMOTEPath" }
#If Remote Fileshare gets outdated, send a warning, but just continue anyway with Main Fileshare for now
else {Write-Warning -Message "Remote SAS DL is Outdated, to increase your download speeds contact ADMIN to Update Remote Fileshare" -Verbose}
}

#Start the install process
#Make sure the temp directory exists
New-Item "$InstallPath" -ItemType Directory -Force

#Download the Zip
$TryCount = 0
Try {
 Write-Progress -Activity 'CopySASFiles' -Status "Copying SAS ZIP File" -PercentComplete 10

     Start-BitsTransfer -Source "$ZIPPath" -Destination "$InstallPath" -DisplayName "SASzip" -RetryInterval 60 -TransferType Download -Priority High -ErrorAction Stop  #-TransferPolicy Unrestricted
     Start-Sleep 2

 # To get here, the transfer must have finished, so set the counter
 # greater than the max value to exit the loop
 $TryCount = $TryCount + 1
} # End Try block

Catch {
 $PSItem.Exception.Message
 Write-Warning -Message "Download of SAS not complete or failed. Attempting retry #: $TryCount" -Verbose
 Write-Warning -Message "If this happens often, you may need a more stable internet connection." -Verbose
 Write-Warning -Message "Or bring your hardware to your closest On-site for installation" -Verbose
 Start-Sleep 5
} # End Catch Block


 #Telemetry checkpoint 1
#User made it past download, lets see how long it took them to download the sourcefiles.
$BenchmarkEnd = Get-Date -Uformat %s
$BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))
Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, CopyZip, $TryCount$BenchMarkTime$VPN"

#Extract the zip
Write-Progress -Activity 'ExtractSAS' -Status "Extracting SAS" -PercentComplete 30
 Expand-Archive "$InstallPath\$ZIPName" "$InstallPath" -Force
#Unzip file performance tested 12.3GB - @ Approx 30 Mins

#Telemetry checkpoint 2
#User made it past Extraction, 
$BenchmarkEnd = Get-Date -Uformat %s
$BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))
Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, ExtractZip, $TryCount$BenchMarkTime$VPN"

#Validate downloaded file - compare with source, fail to error message if not successful.
#Notify your admin that the install is ready
$copiedHash = (Get-Item $InstallPath\$ZipName).Length/1KB
$sourceHash = (Get-Item $ZIPPath).Length/1KB

If (($copiedHash -eq $sourceHash) -and ($null -ne $copiedHash))
{
Write-Host "Download complete, Please contact your assigned technician to complete the install." -ForegroundColor Green
#and popup
$remap=New-Object -ComObject Wscript.Shell; $remap.Popup("Please notify your assigned technician the download is complete, and ready to install",0,"Download complete")

#Telemetry checkpoint 3
#User successfully Validated Hash, 
$BenchmarkEnd = Get-Date -Uformat %s
$BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))
Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, HashCheckSuccess, $TryCount$BenchMarkTime$VPN"

}
else {
 $remap=New-Object -ComObject Wscript.Shell; $remap.Popup("Download FAILED, Please try again.  If this is continuous, you may need a better internet connection or go to your nearest On-Site location",0,"Download FAILED")

 #Telemetry checkpoint 3
#User FAILED Hash Validation, 
$BenchmarkEnd = Get-Date -Uformat %s
$BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))
Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, HashCheckFailed, $TryCount$BenchMarkTime$VPN"

}