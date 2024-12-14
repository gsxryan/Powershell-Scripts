<# RCAutomate.com

Parse a CSV File exported from Nessus reports, and categorize vulnerabilities by numerous priorities
Sort by highest priority vulnerabilities and by team to help delegate remediation.

Prioritize First Observed since they likely have been exposed too long.
Create Definition file of Server name to Assignment
Report summary per user / machine, Sort by highest count.

Suggest Teams to work together on common matching vulnerabilities
Compare Teams Last vulns with this month's vulns, difference, include serverlist
Create category for imaging team: (workstation, vm, laptop)
Ping Ponging Recent/expired vulns (use full scan to locate duplicates, take the oldest first discovered date of all duplicates.)
Add previous month scan to compare differences
#>

#Modify Todays date for running retroactive reports (or date the report ran) get-date for today
$TodaysDate = Get-Date -Year 2024 -Month 12 -Day 31
#This Months report location
$Report = Import-CSV "C:\temp\12312024.csv"
#Last Months report to compare
#$LastReport = Import-CSV "C:\temp\11302024.csv"

<#Cleanup Report Duplicates - Assuming that Each unique host cannot have duplicate plugin vulnerability
for each unique DNS Name, , Sort by First Discovered, Select Oldest
$RepHostnames = ($Report)."DNS Name" | Sort-Object | Get-Unique
#Select Duplicate Plugin
foreach ($Rephost in $RepHostnames)
{Where ()}

($report | Sort-Object $_."Last Observed" | Get-Unique).plugin.count
$ReportDedupe += @([pscustomobject]@{Plugin=$_.Plugin;"Plugin Name"=$_."Plugin Name"}) 

#>

#Server Assignments

#Database team
$Team='Database'
$DBAServers=@('preprod01','oracle01','prod01','science01')
foreach ($server in $DBAServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team}) 
}

#Solaris group
$Team='Solaris'
$VMWareServers=@('application04','db01')
foreach ($server in $VMWareServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team})
}

#Programmers team
$Team='Developers'
$DevServers=@('docker01','app05','applauncher01')
foreach ($server in $DevServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team})
}

#Linux/HPC/Quantum/Redhat
$Team='Linux'
$LinuxServers=@('hpc201','hpc202','hpc203','cactiapp01')
foreach ($server in $LinuxServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team}) 
}

#Windows Team
$Team='Windows'
$WindowsServers=@('DC01','DC02','administrator01','app07'`
,'fileserver01','citrixvda01')
foreach ($server in $WindowsServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team})
}

#Vmware Team
$Team='VMware'
$VMWareServers=@('virtualhost01','virtualhost02','vcenter01')
foreach ($server in $VMWareServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team})
}

#Shutdown: (machines that are shut down that shouldn't be on the report summary totals)
#manually populate these with machines having a scheduled imminent EOL date.
#This deprioritizes these vulnerabilities in the report.
$Team='Shutdown'
$ShutdownServers=@('Server2012-01','WindowsXP01','CentOSapps')
foreach ($server in $ShutdownServers){
    $TeamAssignment += @([pscustomobject]@{Hostname=$server;Team=$Team})
}


#sort report by first discovered
#$sortedreport = $report | Sort-Object $_."First Discovered"
#   Doesn't work: $CritSummary | Sort-Object $_.Date

foreach ($vuln in $report)
{
If (($vuln.Severity -eq "Critical") -or ($vuln.Severity -eq "High") -or ($vuln.Severity -eq "Medium"))
{
        #strip clocktime from First discovered Date
    $Date = (Get-Date ($vuln."First Discovered" -replace (" EDT"), ('') -replace (" EST"), (''))).ToString("s")
    $Status = $vuln.Severity
        #strip FQDN off DNS name
    $Hostname = ($vuln."DNS Name" -replace (".contoso.com"), ('') -replace (".contoso"),(''))
    $Plugin = $vuln."Plugin Name"
    #Plugin Name Exceptions - These have too many unique variations but have common remediation actions
    #Trying to combine them to optimize reporting
    if (($Plugin -match "Oracle Database") -or ($Plugin -match "Oracle Java SE Multiple Vulnerabilities") -or ($Plugin -match "Oracle WebLogic") -or ($Plugin -match "Oracle Coherence"))
    {
        #Remove the Date or detailed info to combine similar vulns
        $Plugin = $vuln."Plugin Name".Split('()')[0]
    }
    $IP = $vuln."IP Address"
    $Metasploit = $vuln."Exploit?"
    
    #Manual IP Address Assignments
    #This is needed to fill the hostname where DNS entries are missing
    #The DNS entries on these should be fixed, but this is a workaround until they do.
    If ($IP -eq "192.168.1.136") {$Hostname="AppLaunch06"}
    If ($IP -eq "192.168.1.134") {$Hostname="StorageHPC"}
    If ($IP -eq "192.168.1.135") {$Hostname="ShutdownEndpoint"} #– cannot ping, maybe this device is no longer used?


    #Add the team assignments to each vuln
    $Assignment = ($TeamAssignment | Where-Object {$_.Hostname -eq $Hostname}).Team
    #Assignment Exceptions
    If (($Plugin -match "Oracle Database") -and ($Assignment -ne "Solaris") -and ($Assignment -ne "Database")) {$Assignment="Database"}

    $CritSummary += @([pscustomobject]@{Date=$Date;Metasploit=$Metasploit;Status=$Status;Hostname=$Hostname;IP=$IP;Plugin=$Plugin;Team=$Assignment})
    #Write-Host "Total Critical:" $CritSummary.status.count
    
}}

#Report precheck run
$UnassignedServers = ($CritSummary | where-object {$null -eq $_.Team}).Hostname | Sort-Object | Get-Unique
If ($null -ne $UnassignedServers)
{Write-Host "Please Assign the following servers and re-run the report"
$UnassignedServers}

$ServersMissingHostname = ($Report | where-object ({$_."DNS Name" -notmatch ".gov"})).'IP Address' | Sort-Object | Get-Unique
If ($null -ne $ServersMissingHostname)
{Write-Host "The following servers are missing DNS name resolution and will not be included in this summary.  They need to be resolved manually in the CSV, or change the code to resolve static IPs."
$ServersMissingHostname}

#Total Critical
#Highest to lowest priority

Write-Host "Total CRITICAL Vulnerabilities:"
($CritSummary | Where-Object {$_.Status -eq 'Critical'}).count
Write-Host "Total High Vulnerabilities:"
($CritSummary | Where-Object {$_.Status -eq 'High'}).count
Write-Host "Total medium Vulnerabilities:"
($CritSummary | Where-Object {$_.Status -eq 'medium'}).count
Write-Host "\
\
"
#Internal application remediation timeline defined
$ThirtyDays = ($TodaysDate).AddDays(-30) #Critical/High
$SixtyDays = ($TodaysDate).AddDays(-60) #Medium
$NinetyDays = ($TodaysDate).AddDays(-90) #Low

<#Public Facing timeline:
$FifteenDays = (Get-Date).AddDays(-15) #Critical
Critical:                15 Days
High:                    30 Days
Medium:             60 Days
Low:                    90 Days 
#>

#Critical First Observed > 30 days.
Write-Host "EXPIRED CRITICAL Vulnerabilities (Exceeds 30 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'Critical') -and (($_.Date | Get-Date) -lt $ThirtyDays)})).count
Write-Host "EXPIRED High Vulnerabilities (Exceeds 30 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'High') -and (($_.Date | Get-Date) -lt $ThirtyDays)})).count
Write-Host "EXPIRED medium Vulnerabilities (Exceeds 60 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'Medium') -and (($_.Date | Get-Date) -lt $SixtyDays)})).count
Write-Host "\
\
"

Write-Host "Recent CRITICAL Vulnerabilities (Within 30 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'Critical') -and (($_.Date | Get-Date) -gt $ThirtyDays)})).count
Write-Host "Recent High Vulnerabilities (Within 30 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'High') -and (($_.Date | Get-Date) -gt $ThirtyDays)})).count
Write-Host "Recent medium Vulnerabilities (Within 60 day limit):"
($CritSummary | Where-Object ({($_.Status -eq 'Medium') -and (($_.Date | Get-Date) -gt $SixtyDays)})).count
Write-Host "\
\
"

#For each team give a summary
$UniqueTeam = $TeamAssignment.Team | Get-Unique
foreach ($item in $UniqueTeam)
{
#Categorize by team (count servers managed) & User (Database, Programmers, Linux, Windows)
Write-Host "$item Team Summary"
Write-Host 'Recent Vulnerabilities 30 days (Crit/High/Med)'
($CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -gt $ThirtyDays)})).count
Write-Host 'Team Vulnerabilities With Known Exploit (EXPLOITABLE - Crit/High/Med)'
($CritSummary | Where-Object ({($_.Team -eq $item) -and ($_.Metasploit -eq 'Yes')})).count
Write-Host 'EXPIRED Critical Vulnerabilities'
($CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -lt $ThirtyDays) -and ($_.Status -eq 'Critical')})).count
Write-Host 'EXPIRED High Vulnerabilties'
($CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -lt $ThirtyDays) -and ($_.Status -eq 'High')})).count
Write-Host 'EXPIRED Medium Vulnerabilties'
($CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -lt $SixtyDays) -and ($_.Status -eq 'Medium')})).count

#Write-Host "Top 10 Common Vulnerabilities for $item Team"
#($CritSummary | Where-Object ({($_.Team -eq $item)})).Plugin | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -first 10 | Format-Table -AutoSize
Write-Host "10 Latest Expired Critical Vulnerabiltiies for $item Team"
$CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -lt $ThirtyDays) -and ($_.Status -eq 'Critical')}) | Select-Object Date,Plugin,Hostname | Sort-Object -Property Date -Descending | Select-Object -first 10 | Format-Table -AutoSize

Write-Host "Top 10 Common EXPLOITABLE Vulnerabilities for $item Team (Crit/High/Med)"
($CritSummary | Where-Object ({($_.Team -eq $item) -and ($_.Metasploit -eq 'Yes')})).plugin | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -first 10 | Format-Table -AutoSize

Write-Host "Top 10 Common Critical Vulnerabilities for $item Team"
($CritSummary | Where-Object ({($_.Team -eq $item)  -and ($_.Status -eq 'Critical')})).Plugin | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -first 10 | Format-Table -AutoSize
#ADD: Sort Matching Count Critical Vulns by descending Critical Score

Write-Host "Top 5 Common High Vulnerabilities for $item Team"
($CritSummary | Where-Object ({($_.Team -eq $item)  -and ($_.Status -eq 'High')})).Plugin | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -first 5 | Format-Table -AutoSize

Write-Host "Top 5 Common Medium Vulnerabilities for $item Team"
($CritSummary | Where-Object ({($_.Team -eq $item)  -and ($_.Status -eq 'Medium')})).Plugin | Group-Object -NoElement | Sort-Object -Property Count -Descending | Select-Object -first 5 | Format-Table -AutoSize
Write-Host "\
\
\
\
"
}

#Audit cleanup 
#machines missing hostname ( use IP )
#($Report | where-object ({$_."DNS Name" -notmatch "hostprefix"}))
#machines not assigned to a group
#($CritSummary | where-object {$null -eq $_.Team}).Hostname | Sort-Object | Get-Unique

#Tools
#Loop to Echo machines having a common Vulnerability
 do {
    $i=1
    $lookupTeam = Read-Host "Which Team do you want to look up?"
    $lookupVuln = Read-Host "Which Vulnerability? (Full/partial plugin name)"
     
    ($CritSummary | Where-Object ({($_.Team -eq $lookupTeam) -and ($_.Plugin -match $lookupVuln)})).Hostname | Sort-Object | Get-Unique

} while ($i=1)
#Vulns on servers that have been shutdown

#Get list of High Expired Vuls 
#($CritSummary | Where-Object ({($_.Team -eq $item) -and (($_.Date | Get-Date) -lt $ThirtyDays) -and ($_.Status -eq 'High')}) | Sort-Object -Property Date -Descending)

#Extended Detail By assignment group
#Newly discovered vulnerabilities (within allowed limits)
#Expired vulnerabilities (outside allowed limits)

#Find Exploitable
#($CritSummary | Where-Object ({($_.Metasploit -eq 'yes') -and ($_.Plugin -match $lookupVuln)})).Hostname | Sort-Object | Get-Unique