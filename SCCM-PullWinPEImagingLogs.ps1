<# RCautomate.com
Gather SCCM Imaging Logs from WinPE Environment
Useful when troubleshooting SCCM Imaging environment errors
#>

$driveletter = "R:"
$year = 2019

#Map R Drive (can be any unused drive where you have writable access)
#Comment this out if you have a separate persistent storage device attached, use that drive letter
net use $driveletter \\fileserver\ImagingLogs /USER:fileserver\loguser Password1234

#Create Directories
New-Item "$driveletter\$year\$env:COMPUTERNAME" -ItemType Directory
New-Item "$driveletter\$year\$env:COMPUTERNAME\C-CCM-Log-SMSTS" -ItemType Directory
New-Item "$driveletter\$year\$env:COMPUTERNAME\C-CCM-Log" -ItemType Directory
New-Item "$driveletter\$year\$env:COMPUTERNAME\_smsts" -ItemType Directory
New-Item "$driveletter\$year\$env:COMPUTERNAME\X_smsts" -ItemType Directory
New-Item "$driveletter\$year\$env:COMPUTERNAME\X_winsmsts" -ItemType Directory

#Copy Logs to Drive
XCOPY "C:\windows\ccm\logs\smstslog\*.log" "$driveletter\$year\$env:COMPUTERNAME\C-CCM-Log-SMSTS"
XCOPY "C:\windows\ccm\logs\*.log" "$driveletter\$year\$env:COMPUTERNAME\C-CCM-Log"
XCOPY C:\_smstasksequence\*.log $driveletter\$year\$env:COMPUTERNAME\_smsts
XCOPY X:\smstslog\*.log $driveletter\$year\$env:COMPUTERNAME\X_smsts
XCOPY X:\Windows\Temp\smstslog\*.log $driveletter\$year\env:hostname\X_winsmsts