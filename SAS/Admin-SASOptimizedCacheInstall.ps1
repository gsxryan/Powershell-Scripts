<#RCautomate.com Optimized SAS Install ZIP/BITS Method
#Wrapping the vendor provided generic SAS Install script which runs the cached installer

#BITS must be run as normal user (non admin) to avoid internet being blocked.  
Technicians should instruct users to double click ahead of time to prepare for installs

#2nd stage requires admin to install the cached files
#This design stabilizes and greatly increases Admin Experience and performance of remote installs for SAS ~12GB
When running per vendor we waste hours on each install using the chatty design.
#> 

#Environment Variables
$InstallPath = "C:\temp\sas"
$ZIPExtrSubfldr = "sas_9_4_M7"
$ZIPName = "SAS_9_4_M7.zip"
$ZIPPath = "\\fileshare.contoso.com\SAS\$ZIPName"
$SASLaunchPath = "C:\Program Files\SASHome\SASFoundation\9.4\sas.exe"
$LogPath = "\\logserver.contoso.com\Telemetry\SAS" #must be writeable
$Machine = $env:COMPUTERNAME
$VPNrange = "^10[.]10[.]."

#gather telemetry
$User = [Environment]::UserName
  #Get Current Date and Time
  $Date = Get-Date -Format d
  $Time = Get-Date -Format T
  $BenchmarkStart = Get-Date -Uformat %s
$VPN = ((Get-NetIPAddress).IPAddress | Where-Object {$_ -match ("$VPNrange")}); if ($null -notmatch $VPN) {$VPN=", VPN"} else {$VPN=""}

#Start the install process as admin

#Run Vendor's launcher
Write-Progress -Activity 'InstallSAS' -Status "Installing SAS" -PercentComplete 30
Write-Host "Starting the SAS Requirements Script"
  Start-Process "$InstallPath\$ZIPExtrSubfldr\installSASPrerequisitesLocal.bat"
Write-Host "WAIT until SAS requirements installation is completed, then press enter" -ForegroundColor Green

#ENHANCE: instead of pausing and relying on technician, start a loop to wait for some type of requirements completion
    pause
Write-Progress -Activity 'InstallSAS' -Status "Installing SAS" -PercentComplete 40
Write-Host "Starting the SAS Install Script"
Start-Process "$InstallPath\$ZIPExtrSubfldr\installSASLocal.bat"

#Telemetry checkpoint 1
#Admin made it past installation, lets see how long they waited to clean up files to estimate cached installation time.
$BenchmarkEnd = Get-Date -Uformat %s
$BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))
Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, AdminInstallStart$BenchMarkTime$VPN"

#prompt to WAIT for installation completion, then cleanup the install directory
Write-Progress -Activity 'CleanSAS' -Status "Cleaning up SAS Installer" -PercentComplete 90
Write-Host "WAIT until SAS installation is completed, then press enter" -ForegroundColor Green
pause
Write-Host "Attempting to Launch SAS"
  Start-Process $SASLaunchPath
write-host "Press Enter ONLY if SAS launches successfully The next step DELETES the source content." -ForegroundColor Yellow
Write-Host "To NOT delete source content: close the window" -ForegroundColor Red
pause
write-host "Cleaning up install temp directory" -ForegroundColor Green
  Remove-Item "$InstallPath\$ZIPExtrSubfldr" -Recurse -Force

  #remove the ZIP
Remove-Item "$InstallPath\$ZIPName" -Force

#Final telemetry - log usage for total time, includes the time users WAITED at a pause screen (may make install times highly variable if unattended)
  $BenchmarkEnd = Get-Date -Uformat %s
  $BenchmarkTime = (", " + ([math]::Round($BenchmarkEnd) - [math]::Round($BenchmarkStart)))

Add-Content $LogPath\$Machine.log "$Date, $Time, $User, $Machine, AdminInstallFinish$BenchMarkTime$VPN"

