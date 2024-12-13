<# RCautomate.com
This is the preliminary structure for a SCCM CI that could run and gather PC telemetry.
The purpose of this telemetry is to identify anomalies in a specific running process.
The primary case for this script was to identify memory leaks in McAfee fcags.exe
A bug was reported and root cause identified with help of this analysis.
This could be useful for tracking other instances as well.

Currently configured to run continuously in a 15 minute loop.
Reporting on this interval allows checkpoints to observe the $EXE RAM pool balloon up.
Reporting all this other data at the same time allows RCA to be found.

Monitor.csv could be variable, and centralized to bring all reports to a central location from many PCs
Add: check if file exists, if not, halt

#Get Non-Paged RAM utilization
#>

#enter the executable running in memory to monitor
$EXE = "fcags.exe"
$monitorCSV = "C:\Temp\monitor.csv"

#GET PC UPTIME
function Format-TimeSpan {
    process {
      "{0:00} d {1:00} h {2:00} m {3:00} s" -f $_.Days,$_.Hours,$_.Minutes,$_.Seconds
    }
  }


Write-Host "Date, Uptime, Model, Username, BIOS, CPULoad%, AvailableRAM, PageFileAvail, Handles, PageFile, SysPagefile Peak, Quota NonPaged Use, Quota NonPaged Peak, Version"
Add-Content $monitorCSV "Date, Uptime, Model, Username, BIOS, CPULoad%, AvailableRAM, PageFileAvail, Handles, PageFile, SysPagefile Peak, Quota NonPaged Use, Quota NonPaged Peak, Version"

$totalRam = (Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).Sum
while($true) {
    $date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $cpuTime2 = (Get-WmiObject Win32_Processor).LoadPercentage
    $availMem = (Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue
    $PageFile =  (Get-CimInstance Win32_OperatingSystem).SizeStoredInPagingFiles
    $BIOS = (Get-CimInstance Win32_BIOS).Name
    #Get CPU Handles
    $Handles = (Get-CimInstance Win32_Process | select * | Where-Object {$_.ProcessName -match "$EXE"}).Handles
    $PageFileUse = (Get-CimInstance Win32_Process | select * | Where-Object {$_.ProcessName -match "$EXE"}).PageFileUsage
    $SystemPageFilePeak = (Get-CimInstance Win32_pagefileusage).PeakUsage
    $QuotaNonPagedPoolUsage = (Get-CimInstance Win32_Process | select * | Where-Object {$_.ProcessName -match "$EXE"}).QuotaNonPagedPoolUsage
    $QuotaPeakNonPagedPoolUsage = (Get-CimInstance Win32_Process | select * | Where-Object {$_.ProcessName -match "$EXE"}).QuotaPeakNonPagedPoolUsage
    $Version = (Get-CimInstance Win32_Process | select * | Where-Object {$_.ProcessName -match "$EXE"}).WindowsVersion
    $Model = (Get-CimInstance Win32_ComputerSystem).Model
    $UserName = (Get-CimInstance Win32_ComputerSystem).UserName
    #get uptime
    $LastBootTime = (Get-WmiObject Win32_OperatingSystem).LastBootUpTime
    $LastBootTimeDate = [Management.ManagementDateTimeConverter]::ToDateTime($LastBootTime)
    $Uptime = (get-date) - $LastBootTimeDate | Format-Timespan
    Write-Host $date',' $Uptime',' $Model',' $UserName',' $BIOS',' $cpuTime2',' $availMem',' $PageFile',' $Handles',' $PageFileUse',' $SystemPageFilePeak',' $QuotaNonPagedPoolUsage',' $QuotaPeakNonPagedPoolUsage',' $Version
    Add-Content $monitorCSV "$date, $Uptime, $Model, $UserName, $BIOS, $cpuTime2, $availMem, $PageFile, $Handles, $PageFileUse, $SystemPageFilePeak, $QuotaNonPagedPoolUsage, $QuotaPeakNonPagedPoolUsage, $Version"
    Start-Sleep -s 900 #15min sleep
}
