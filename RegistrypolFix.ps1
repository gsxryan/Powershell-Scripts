<# Suspecting that registry.pol file corruption causes the following issues
        -Bitlocker will not properly install MBAM & Encrypt (FVE registry key error)
        -Slow boot times (GPO apply times extended)
        -certs not being received (Domain trust is lost)
        -improve long term SCCM client health (Patch compliance may suffer)
        #ADMINISTRATOR access is required to remove the registry.pol file
        Alternative: CMPivot Query:  File('C:\Windows\System32\GroupPolicy\Machine\Registry.pol') | project Device, FileName, Size, LastWriteTime
#>

$RegPolPath = "C:\Windows\System32\GroupPolicy\Machine\Registry.pol"

$LogDir = Telemetry\RegistryPol

$Computername = $env:COMPUTERNAME

$AgedDate = (Get-date).AddDays(-20) | Get-Date -Format yyyyMMdd

 

#Check the Encoding Byte Prefix

$BytePrefix = Get-Content -Encoding Byte -Path $RegPolPath -TotalCount 4

#Get the Last time the eventlog hanlded a GPO error:

$GPOTime = (Get-WinEvent -FilterHashtable @{LogName="Application";ID=4098}) | Select UserID,TimeCreated,Message -First 1 | Format-Table -Wrap

#The date this errors occurs, you should notice that the users' history also is stuck at that date: [deleting these did not fix the issue]

#C:\ProgramData\Microsoft\Group Policy\History

#Refreshing the user profile should also fix this issue, but will be potentially high impact to the user.

 

#What is the file age?

$LastWrite = (Get-ChildItem $RegPolPath).LastWriteTime | Get-Date -Format yyyyMMdd

$LastAccess = (Get-ChildItem $RegPolPath).LastAccessTime | Get-Date -Format yyyyMMdd 

 

#Make a copy for backup / for further troubleshooting

Copy-Item $RegPolPath "$LogDir\$Computername-$LastWrite-$LastAccess.pol"

 

# If the Last WriteTime is greater than 20 days, Delete the pol file and run gpdupate

# You must be an admin to remove the file

If ($LastWrite -lt $AgedDate)

    { 

    Remove-Item $RegPolPath

    #force gpupdate to build a new pol file

    gpupdate /force

    #echo "yes"

    }

 

#Did the machine also have Event Viewer errors containing GPO messages?

    #Failed to open GPO (0x80004005)

    #Event 4098, WARNING, SYSTEM, PreventCertErrorOverrides, Specified Path was invalid, 0x800700a1

    #The eventlog errors seem to STOP when the registry.pol file gets corrupt.  Reference:

#(Get-WinEvent -FilterHashtable @{LogName="Application";ID=4098}) | Select UserID,TimeCreated,Message -First 1

 

#Log things [DEVELOPMENT]

#$LogDir, $GPOTime

 

<# An error may then persist where GPO can still not be refreshed.

Computer policy could not be updated successfully. The following errors were encountered:

 

###### Rebooting will regenerate registry.pol, but will not fix this next issue

 

The processing of Group Policy failed. Windows attempted to retrieve new Group Policy settings for this user or computer. Look in the details tab for error code and description. Windows will automatically retry this operation at the next refresh cycle. Computers joined to the domain must have proper name resolution and network connectivity to a domain controller for discovery of new Group Policy objects and settings. An event will be logged when Group Policy is successful.

User Policy update has completed successfully.

 

Perform:

SFC /scannow [gpo will still fail]

DISM /online /cleanup-image /restorehealth [gpo will still fail] [UNKNOWN fix]

 

CBS.log - Not applicable to issue

Many:

Info                  CSI    00000090 Warning: Overlap: Directory \??\C:\WINDOWS\System32\drivers\en-US\ is owned twice or has its security set twice

   Original owner: Microsoft-Windows-Foundation-Default-Security.Resources, version 10.0.19041.1, arch amd64, culture [l:5]'en-US', nonSxS, pkt {l:8 b:31bf3856ad364e35}

   New owner: Microsoft-Windows-Foundation-Default-Security.Resources, version 10.0.19041.1, arch amd64, culture [l:5]'en-US', nonSxS, pkt {l:8 b:31bf3856ad364e35}

 

   One:

   2022-10 Info                  CSI    000001ed [SR] Repairing file \??\C:\Users\Default\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\\OneDrive.lnk from store

 

#>