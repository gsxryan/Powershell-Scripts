### “Effective communication is automating it away—it no longer requires thought, effort, or delay.” -| RCautomate.com

> Automate the words,  
> Communication fades fast—  
> No thought, no delay.  
> Effective execution,  
> Process perfect flow.

#### CTRL+F Find Files

## SCCM / MECM Misc Scripts
 - **ActivSetupReg-RunonceEachUser.ps1**
 For situations where you need to deploy a script to each logged on user on a machine ActivSetup can be a good solution.  This utilizes versioning, so it will only deploy once to each user, until the version increment in registry is increased.  Utilizing this with SCCM can make it even more powerful strategy for configuration management.

- **Java-Portable / Portable-JAR.ps1**
When developers have not delivered a launching mechanism for JAR files and are relying on the default Java installed on users desktops, there can be frustrating configuration drift across the enterprise.  Even if a Java client standard is set and deployed, some applications may come with their own constraints for requiring a specific version.  Utilizing this portable launcher with the specific Java files required, can mitigate some of the frustrations users and T2 admins encounter with managing this environment.

 - **JavaExceptions/JavaExceptionSitesCI.ps1**
 The following STIG may be applied to your enterprise, or similar AD Java restriction in browsers, preventing your users from adding Java site exceptions to their local java clients to run unsigned Java code.  This script ensures the website is in each machine's local Java Exception sites. PLEASE avoid using this method if at all possible.  It can open your company up to MITM attacks with malicious code injection.  If your developers are unable to sign their Java code, or the vendor cannot sign their code then this CI can be deployed to the Desktops that require access to the Java site.  The intention of this script should only be to temporarily allow access while a better solution is developed.
 Another alternative may be to package these applications into remote sandboxes such as Citrix or Azure Virtual Desktop.  Or, to package a portable JAR file with the Java Application deployment (See Java below for an example application for this method).

 
 [jre_version_7_windows_7/2015-12-10/finding/V-32828](https://www.stigviewer.com/stig/java_runtime_environment_jre_version_7_windows_7/2015-12-10/finding/V-32828)
 

 - **MappedNetDriveScraper.ps1**
 This script will run in the user context to dump all mapped network drives.  This can be useful when planning a user profile migration or determining which file servers are still in use.  A DEV item was left to use NT*.dat file to utilize an admin account to search all machine profiles mapped drives, but the project I worked on did not need to utilize this extent yet.
 
 - **MemoryHandleTracing.ps1**
 The purpose of this telemetry script is to identify anomalies in a specific running process.  The primary case for this script was to identify memory leaks in McAfee fcags.exe.  A bug was reported and root cause identified with help of this analysis.
This could be useful for tracking other instances as well. It will report at 15 minute intervals very detailed RAM usage (ballooning non-paged pool), along with Uptime, Model, Username, BIOS version, CPULoad%, AvailableRAM, Handles, PageFile, Pagefile Peak, Quota NonPaged Use, Quota NonPaged Peak, and EXE Version.  For future ideas a 2nd exe could be added to this to simultaneously monitor on many machines.  A version mismatch with machines having errors could indicate incompatibility.

 - **MigrateUserPrintersPaths.ps1**
 If the organization did not deploy network printers to user profiles without a common network prefix, and/or the DNS records cannot yet be migrated, this script may be useful to migrate all currently mapped user printers to a new path.  This must be run within the user context, while they are logged in, and a common network path they should have write access to writes telemetry log output to review for success / failure.  This will benefit gains in understanding who, how many, and what network location the printers on every machine in the enterprise are mapped to for future printer modernization or planning.

 - **OneDriveAvailableOffline.ps1**
Some users wish to have their onedrive file available offline always.  They may travel often, or commonly not have access to the internet.  You may have a group you wish to force these settings to, so the users will not need to encounter the issue of being in a spot without their files downloaded.  This script was drafted and partially tested.  Additional functionality will need to be added to have a successful deployment of this.

 - **SCCM-PullWinPEImagingLogs**
 Useful if your environment utilizes WinPE environment for Imaging Desktops.  This captures logfiles from both the pre-and post-imaging states to ensure you get full coverage when troubleshooting issues with imaging completion.  You can then utilize grep or Select-String in powershell to find keywords or error messages related to your issue.

- **Sigmaplot/SigmaplotALLusersLicense.ps1**
This vendor requires T2 to install a license manually on ALL user profiles on each machine.  Applicable to Sigmaplot 14.5 and below.  Not confirmed on 15+.  This is quite burdensome for T2, so this script was created to mitigate hundreds of service request tickets to manually install the license.  This Installs license to all existing users that have accounts on a single machine.  Additionally, ensures each new user that logs in gets the current license registration.  Utilizes ActiveSync registry to install the license on new user logins so they will also have access to Sigmaplot.  Without these mitigations T2 support will need to reinstall the sigmaplot license and enter custom information for each unique user where Sigmaplot is installed.

 - **RCAScanner-DLP38Citrix**
 Template to scan application versions on all machines to identify RCA.  This could be modified for other applications you suspect may conflict with each other to identify trends between Healthy and Unhealthy machines.  In this case users were reporting issues with attached USB Devices.  This will scan all attached USB devices and look for a specific error state (Code 38).  We suspected a conflict between Citrix and McAfee after taking a look at Installed Applications versions manually.  We needed to extend this to all machines that could have USB issues before they became a problem for the help desk.  The root cause from this script was detected to be an error between a specific version of Citrix Receiver, and McAfee DLP on a specific Hardware model.  In the short term, the Citrix Version was updated on those models before the Help Desk was consumed with service calls.  In the long term, both clients were updated.

- **Misc**
Sigmaplot Licensing Path: C:\ProgramData\SafeNet Sentinel\Sentinel LDK
Setting Outlook presence indicator to teams(alternatives Lync, Cisco Jabber, Zoom): 

```new-itemproperty -path "HKCU:SOFTWARE\IM Providers" -name "DefaultIMApp" -propertytype String -value "Teams" -force```

## Windows Operations
### For Windows Server/Desktop Administrators, Tier 2 Help desk, Root Cause Analysis, etc

 - **Clean-DuplicateLines.ps1**
When you have many text files that have duplicate lines, this script can be useful to sort, and eliminate any duplicate lines for increased efficiency.

 - **Compare-Certificates.ps1**
Compare the Certificates between two machines.  This can be useful to determine certificate or authentication behavioral differences between PCs.

 - **Compare-FolderContents-SHA256.ps1**
 Compare two separate paths (2 servers) folder contents using each files SHA256 hash, and find the differences.  This can be useful when diagnosing issues between two applications or server behavior.  I specifically have used this to reverse engineer application ini or configuration files to declare closed source properties manually.

 - **DeleteEmptyFolders.ps1**
Search a directory and subfolders for empty folders.  If there are any identified, print them to screen for confirmation and then delete them if desired.

 - **ExtractICOfromEXE.ps1**
 Extracts an ico image file from an EXE.  This can be useful if building your own custom shortcuts for user delivery.

 - **FileExclusionScanner.bat**
A legacy batch script that was retired before converting to powershell.  A backup solution excludes some file extensions from backup folders to reduce the expense of storage at the enterprise.  T2 would like to have the users run this to communicate to them which files they need to make provisions on their own to create backups.  Included are common large data file extensions and can be reduced to optimize storage overhead. (installers, virtual machine files, statistical data files, database, cd images, music files)

 - **FlexLM.ps1**
 This script assists with automating migration of the local client license configuration files for various licensing software.  It allows you to paste in a list of machines and will iterate through them to replace the licensing files.  It requires a fileshare to copy the new files from.  It also partially documents how to build a remote monitoring service to ensure that the health of the service is maintained.

 - **FolderFullPermissions.ps1**
 One that should be used as a last resort for application useability.  Policy should be modified instead, but this can be a temporary workaround, or used in troubleshooting the source for application permission issues.  In this example VSCode is tested to allow automatic updates.

 - **HomeFolderADCleanup.ps1**
This in general is for cleaning up inactive user's home folders on a file share.  From a list of user file directory folders, take each name and scan for inactive accounts.  The account file directories that are inactive, mirror the data to a archive path.  From the source path, make sure to delete the data after it's been successfully archived.

 - **InstalledAppCondition.ps1**
 When executing, it will detect if the client has an application installed, and take an action if it is not.  This can become useful if your enterprise has decided it will not automatically deploy a specific piece of software, and the users must manually install it themselves.  In this example, it detects Citrix Workstation, and if it's not installed, will instruct and take the user to the SCCM Software Center to be installed by self service.  Once the dependency is installed, the application will launch internet explorer, and take the user to the Citrix Storefront page.  This automates some of the user instruction, easing some burden on the help desk.  

 - **JavaExceptions/JavaExceptionSitesUser.ps1**
 This script will assume the logged on user had an issue with Java site launching.  Policy is restricting unsigned code being run.  See "Java" above for disclaimer.  It utilizes User permissions, so a shortcut to the script can be deployed to users that can run it with self-service, or a technician can easily instruct them to run it without remote access.  This will detect if the exception.sites file has been defined to the user profile path yet.  If not, it will copy it from the specified file share.  The specified file share is assumed to be hosting a list of sites to be excepted for Java Checks.  The exception.sites file is a centralized, managed file with only user read access.  Users/Everyone should never be granted access to modify the remote file.

 - **KeepAlive.ps1**
A technician keeps getting logged out of their remote session while installing an application that takes a very long time to complete (hours).  Application owners have not invested in developing a silent installer distributed by the enterprise.  Disconnect and Logout policies exist for inactivity that the technician cannot modify.  The installation process does not count as user activity.  Technician must attend to the machine manually, and remember to make some kind of activity on the remote session once every 14 mins while waiting.  This can often result in logged out sessions, requiring the installers to restart from the beginning.  This wastes time and negatively effects the teams KPIs.  Running this script on the remote machine allows the technician to ignore the machine during the install process, and is able to start on another customer simultaneously.  This greatly increases the effectiveness of their team.

- **McAfeeFDEAcctMon.ps1**
After a technician images a users PC and have arrived to collect the laptop, the tech will provision the users FDE login password.  This script will ensure that the users account has been provisioned, and can assist with first account login before departing the imaging lab.  This is applicable to companies that utilize McAfee FDE with bootup password required, and wish to optimize the PC delivery process.

 - **ModifyShortcutPath.ps1**
 Instead of replacing shortcuts, modify only the paths.  This can be useful when attempting to maintain the ico and extended attributes without re-creating them from scratch.  If the shortcuts were created manually, and you have numerous ones to manage, this can be utilized.

- **MonitorRunningService.ps1**
Query a running executable and output if it is active or not.  This can be useful when monitoring a application and ensuring that it stays running.

- **NonBaselineImageSoftware.ps1**
Run this script on a PC that is suspected to have installed software drift from the enterprise baseline.
Software installation drift can cause various issues with the hardware, and identifying what is foreign is a great first step to find the culprit.
This is also useful when migrating a users PC.  It can help identify forgotten requirements from the user.
**This allows T2 to be proactive, mitigating future tickets and lost productivity as a result of PC refresh.**

- **OnPremImageTopoff.ps1**
When delivering a PC, this script optimizes the technician and the user experience to reduce future ticket requests, and ease user onboarding to their new PC.  Some users in the organization may require an application be installed, and have common issues with self-service after machine delivery.  The technician can identify which applications the user may wish to utilize proactively without even needing to ask them.  This utilizes defined AD groups to determine software the user should be associated with.  In this example citrix is used, opening SCCM software center to self-service pull the receiver software.

 - **PsExec-SCCMRemoteInstall.ps1 and PsExec-BatchRemoteInstall.ps1**
 I would recommend looking into Ansible for standardizing operations automation tasks like this. Specifically for SCCM, utilize the builtin tools unless attempts have already failed.  You may have a use case needing to quickly resolve a software deployment project without as much oversight needed using binaries already builtin.  This is specific to installing SCCM Client on remote machines without having to RDP into each machine.  However, the batch files executed could be swapped out to remotely deploy with PsExec on any other silently installed applications.  The only dependencies assume you have PSEXEC.exe already downloaded to the current working directory, you are an administrator on the remote machines, and policy allows PSEXEC to run.  Modern threat agents may assume suspicious behavior from PSEXEC, as lolbin, so utilizing your enterprise standard remote deployment tools is recommended.

- **RDPlockup-DisableUDP.ps1**
In some environments anyone utilizing Remote Desktop may encounter screen locking, no response from input.  Disabling UDP on RDP can make the session connections more reliable in these environments.  This script sets a registry path to accomplish this.

- **RecentlyInstalledSoftware.ps1**
Can be used to determine the latest changes on a PC (installed software, or updates).  This is useful when performing RCA, determining what might have caused recent issues on machines reporting common issues.

- **RegistryPOLfix.ps1**
Suspecting that registry.pol file corruption causes the following issues.  This script makes an attempt to gather data from suspected endpoints and identify trends.  It will also remediate so the problem should not persist.  This was an issue documented on many forums effecting Windows 10.  I'm not sure if this persisted with Windows 11 as my role transitioned away from this type of activity.  -Bitlocker will not properly install MBAM & Encrypt (FVE registry key error), -Slow boot times (GPO apply times extended), -certs not being received (Domain trust is lost), -improve long term SCCM client health (Patch compliance may suffer). 

Alternative CMPivot Query:    ```File('C:\Windows\System32\GroupPolicy\Machine\Registry.pol') | project Device, FileName, Size, LastWriteTime```

- **SAS \ Files, Remote Fileshare Installer optimizer**
This folder and collection of files was originally designed for SAS installer.  The sourcefiles are 16+GB, and have MANY files.  This creates challenges for T2 installers when attempting to install for clients on VPN or remote sites with slow connections.  Especially when the sourcefiles are not local.  This featureset integrates a two stage process.  1) which can have the users prestage the installer files locally without technician internaction.  2) once prestaged the admin is contacted to complete the install in an optimized environment.  This has saved from 1-8 hours of dwell time on waiting for the installer to complete per install.  One technician can now complete from 8-16 installs a day, compared to 1-4 installs per day.  This solution could be adapted to fit other large install programs.  The best solution would be to combine a more optimized central installation mechanism with SCCM, but some environments may not wish to invest in integration with the enterprise tool, and rather utilize their call center.

- **ScheduledTask.ps1**
This is ideal for running administrative tasks or maintenance scripts that need to be executed immediately without manual intervention. For example, applying configuration changes, collecting logs, or running diagnostics.  The task can be remotely scheduled, and executed at a time specified.  In this example a 60 second timer is initiated for immediate deployment.  It is particularly useful for one-time or ad hoc tasks that do not need a permanent presence in Task Scheduler. This approach minimizes long-term overhead and avoids clutter.
After execution, the script removes the scheduled task, maintaining a clean and secure system state. This is particularly valuable in scenarios where automation scripts are used for troubleshooting or quick fixes, and there’s no need to retain the scheduled task after execution.

- **SmartCardTroubleshoot.ps1**
Can be useful to help troubleshooting misbehaving smart card, PIV, CAC cards when they are not detecting properly, or fast enough.

- **TXTfileperCSVentry.ps1**
Using existing CSV file, choose a specific column.  For that column, each value that is populated will create a $value.txt file.

- **MachAvailMon-PingAD.ps1**
This script makes an attempt to optimize the issue with T2 call, no answer.  Avoiding spending time leaving excessive emails or messages to the customer and waiting for callbacks.  Ensure that the PC is online, and active in AD, another partial stage will notify that a user is online when their Teams status becomes online, ensuring that they should be available to respond.  At the time it utilized the SkypeAvailability script, which is published in UserAvailMon-Skype.ps1.  This is a placeholder to note that this optimization can be redeveloped using teams.  It attempts to confirm both network connectivity and the existence of a corresponding Active Directory object for each hostname.
Outputs relevant information about each hostname (e.g., AD details, online status).

- **PingBySpecificPort.ps1**
Take a batch list of machines and ping them.  This will prompt for a list of machines, and a specific TCP port, if you wish to not default to ICMP.  

- **SQL-AuditHTMLreporttoEmail.ps1**
Query a SQL Database with powershell.  Output all system account users and their account status (inactive, active).  These counts are then output to a pretty HTML format and emailed to a group of users.  This is useful for periodic audit and monitoring for Aperio eSlideManager user accounts.  For example, you can monitor if a unapproved administrator account is created, or users have permissions they should not have.

- **UserAvailMon-skype.ps1**
Reports ICMP Ping + Skype User Availability, for use when identifying idle systems to RDP into to complete work that has not yet been automated for deployment.  Users that will commonly not callback for service calls can be monitored for activity.  When their machine is online, and inactive, we can login to complete our work without interrupting the user.  For example, a user is not commonly available, but we catch them on their lunch break to do some maintenance that has not been able to be completed on their workstation.  As they are AFK, and their user profile state is maintained, we will not disturb them, and can close the service ticket.

- **UserStandardizeShortcut.ps1**
This will cleanup user generated, or other non-standard managed shortcuts from every users desktop on each machine.  It will also remove any shortcuts set to generate on new users first login.  After cleanup it will upload the enterprise managed shortcut to the Public profile, so each user on the machine will have a managed standard shortcut.  This can help eliminate confusion in the help desk by standardizing managed application access.

- **x64x86pathfailover.ps1**
Detect if a specified program is x64 installed.  Prioritize that path.  But, if it does not exist, failover to the x86 path.  The example uses chrome browser.

 - **Misc**
 Get Health of machines Registry.pol to detect for potential compliance health issues


 ```(Get-Content -Encoding Byte -Path \\$hostname\c$\Windows\System32\GroupPolicy\Machine\Registry.pol -TotalCount 4)```

 - **robocopy** commands to sync folders

robocopy source destination mirror (make sure destination doesn't exist) /Z (restartable mode) 
#/W (wait between retry) /R:4 (only retry 4 times) /fft ( fat file times, legacy beneficial if both volumes are not NTFS)
#/MT (multithreaded 8x, higher CPU use)


 ```robocopy "$Source\$user" "$dest\$user" /E /Z /W:2 /R:30 /fft /MT:10 /LOG+:D:\RoboCopy.log```
 - Audit

 ```robocopy "$Source\$user" "$dest\$user"  /e /l /ns /njs /njh /ndl /fp /LOG+:D:\RoboCopyAudit.log```

### For End User continuous improvements
- **SearchALLExcel-resultTXT.ps1**
This allows users to search using a keyword on all XLS and XLSX files in a subdirectory.  It will export to CSV, do a search on the CSV Flat files to find, then export data to text file and display the information in notepad.

## InfoSec
- **ChromeForceAutoupdate.ps1**
This is an attempt to elevate compliance for chrome installs that are out of date.  As the user, force open chrome, give it time to use autoupdate policy to regain compliance. Recenter chrome as active window, and close it

- **LastActivityCheck.ps1**
Run a timer that resets when keyboard or mouse input is detected.  Hunt for stealthy mouse jigglers, or scroll lock spammers built in to conference kiosks.  Additionally, continuous logging could be built into this as a persistent service to detect if there is a consistent activity on a schedule.  
Ex: the mouse jiggles every 3m.  You will be able to see history of device activity every 3m.

[microsoft_windows_11/2022-06-24/finding/V-253297](https://www.stigviewer.com/stig/microsoft_windows_11/2022-06-24/finding/V-253297)

- **NessusCSVreportPrioritizer.ps1**
Parse a CSV File exported from Nessus reports, and categorize vulnerabilities by numerous priorities.  Sort by highest priority vulnerabilities and by team to help delegate remediation.


- **ServicesStopDisableReport.ps1**
 Stop a Service, Disable the Service, and then report to confirm it's status.  In this example, the printer spooler is used.

[rintnightmare-critical-windows-print-spooler-vulnerability](https://www.cisa.gov/news-events/alerts/2021/06/30/printnightmare-critical-windows-print-spooler-vulnerability)

- **UserLoginUptime.ps1**
Runs during the users logged in session.  It will continue to count time as soon as it starts.  This can be useful when testing or troubleshooting the session logoff policy delay in remote sessions.  
Ex: the session may disconnect, but leave the user logged in.  After re-establishing the connection, you can detect the time the session was idle, disconnected without having been logged out.

[2012_r2_member_server/2015-06-26/finding/V-3458](https://www.stigviewer.com/stig/windows_server_2012_2012_r2_member_server/2015-06-26/finding/V-3458)

# Active Directory

- **ADLockedAccountMon.ps1**
Script gathers the Active Directory lock state of an account and reads out the status on 15 second intervals.  This can be useful for troubleshooting a continuously locking account.  You can determine the length of time between lock frequency, and compare it to lockout policies to determine how often a foreign script may be forcefully locking the account.

- **MISC**
Some of the functions used in prior scripts have been broken down here in the readme to not get too specific about how you want to gather input or export results.
This can be useful when generating phased test rings in a staged software deployment strategy.

**-Get-ADUser**

Get users that contain a specific physical office designation.  

```get-aduser -LDAPFilter "(physicaldeliveryofficename=CONTOSO/SITE/DIV/OFFICE)" | select GivenName, Surname, SamAccountName```

**-Get-ADComputer**

Get computers in AD that match a particular OU property.

```(Get-ADComputer $hostname | where {$.DistingushedName -match "Accounting"}).DistinguishedName```

**-Get-ADGroupMember**

Get users that are a member of a specific AD Group:

```(Get-ADGroupMember -Identity "Contoso CustSupport").name```

**-Get-ADOrganizationalUnit**

Get computers in AD that match an exact OU path

```$list = (Get-ADOrganizationalUnit -SearchBase "ou=exempt,ou=instruments,dc=rcautomate,dc=com" -Filter *).DistinguishedName```

select only the objects that are enabled

``` foreach ($pc in $list) {$advlist = += (get-adcomputer -Searchbase "$pc" -Properties -Name -Filter * | Where-Object {$_.Enabled -eq $true}).Name}```


sort and dedupe

``` $advlist | Sort-Object | Select-Object -Unique```

### Audit: 
Display all service accounts that have not recently rotated passwords.  This export can be used to determine compliance with passwords needing to be reset every $X days.
```
$datereset = (Get-ADUser -Filter 'Name -like "SVCacctPrefix*" -and Enabled -eq "True"' -Properties PasswordLastSet).PasswordLastSet
foreach ($acct in $datereset){Get-Date $acct -format "yyyy-MM-dd"}
```

 - **Compare-UserFolder-ADHomepath.ps1**
 Uses: Compliance: Ensure user directories are correctly provisioned and de-provisioned according to AD.
Cleanup: Identify and potentially delete orphaned directories to save storage.
Troubleshooting: Detect misconfigured or missing homedirectory entries in AD for users who might be experiencing access issues.

# Powershell

**IDPrimaryUserFromList.ps1**
This will identify the primary user remotely on a list of machines you input.  This can be useful if you've been unable to identify a primary machine user by other means, or the primary user is suspected to be incorrect.  Also can be useful when attempting to track down machines for property management.

```(Get-WmiObject -Class win32_process -ComputerName $Hostname -ErrorAction SilentlyContinue | Where-Object name -Match explorer -ErrorAction SilentlyContinue).getowner().user```

**Intake Data from csv that contains a header**

```$computers = Import-Csv C:\Users\RCurtis\Documents\icd.csv -Header HN; foreach ($item in $computers.Hostname){}```

**Use PSEXEC with a batch list of machines, execute powershell code remotely**
This script will grab the local machine certs to check validity.  Can be useful when troubleshooting NAC 802.1x, or CAC/PIV authentication issues.

```PsExec.exe -s -c -f @PCs.txt powershell "Get-ChildItem Cert:\LocalMachine\My -Recurse | Select Subject, NotAfter"```

**PSEXEC with CAC, PIV, or yubikey SmartCard**

```runas /smartcard "psexec \\hostname powershell.exe -windowstyle hidden -execution policy bypass -file \\contoso.com\script.ps1 & pause"```

**Download multiple JAR in pack200 format**

This downloaded IPA JAR files for portable application launching for non-admin accounts.  This link is no longer kept current, but JARS can be retrieved from desktop installer.

```('ipa', 'appThird1', 'appThird2', 'commonThird') | foreach { (Invoke-WebRequest -Uri "https://analysis.ingenuity.com/pa/public/$_.jar" -Outfile "C:\Temp\IPA\$_.jar" -ErrorAction stop -Headers @{'Accept-Encoding' = 'pack200-gzip'; 'Content-Type' = 'application/x-java-archive'})}```

**Pipe output to an external logfile**
Must have write access to fileshare or path

``` | Out-File -FilePath \\fileserver01\Telemetry\output.log -Append```

**Get Hostnames by IP address method**
A .NET class that performs a reverse DNS lookup

```$hostname = [System.Net.Dns]::GetHostByAddress($IP.IP).Hostname```

Omit the .NET class dependency and use builtin cmdlet

```Resolve-DnsName -Name $IP -Reverse```

**Get the OS build number**

```(Get-WmiObject Win32_OperatingSystem).BuildNumber```

**Workaround: .ssh folder may become inaccessible**

```cd C:\Users\User.Name; takeown /F ".ssh" /d Y /r;``` 
Delete the folder, then ask user to login

# Batch

**InstallTemplate.bat**
An example bat file installer using generic language.  The license installer example uses Lasergene DNAstar

**Prerequisite Redistributable**

```"%~dp0vcredist2012_x64.exe"```

**Silent EXE installer switch**

```"\\fileshare01\installers\App76\App76_setup_x64.exe" /s --ini="\\fileshare01\installers\App76\setup.xml" --logdir="C:\Program Files\Contoso\Logs"```

**Alternate logfile method**

```%~dp0setup.exe /v "/lv C:\Progra~1\Contoso\Logs\App315.log /qb CUSTOM_PROPERTY=True"```

**Silent MSI installer switch**

``msiexec.exe /i "%~dp0setup.msi" /qb /l*v "C:\Program Files\Contoso\Logs\App315.log" REBOOT=ReallySuppress``

**Powershell script start**

```SET PSPath=%~dp0CopyLicense.ps1; Powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%PSPath%'";```

# Crypto

- **MiningAndGaming.ps1**
For those gamers utilizing their graphics power for Nicehash or other client mining, this automation ensures that mining stops when gaming starts.  And mining resumes when gaming stops.  

## Burstcoin (dead coin?)
- **burstcoin-filename-textfile.ps1** 
    List the filenames in each drive, and output them to a text file.

## StorJ
- **StorJV2NodeHealthAPIgrabber.ps1**
This Scanned the old V2 API endpoint to monitor storj farmer node health.  NodeID, Reputation, and responsetime were injected into a influxDB for realtime monitoring in Grafana Dashboards.
- **StorJ Node Health Monitor (Bash)**
Developed very early on the StorJV3 project.  This was forked by the community and has matured into a script thousands have utilized to monitor node health.  https://gist.github.com/gsxryan/d23de042fce21e5a3d895005e1aeafa7

## Veriblock (unlisted, news soon?)

- **Veriblock PoolList**
Maintain a list of currently mined pools. (archived)
https://gist.github.com/gsxryan/c8de9faf79a7f29bb96d925702096023

- **Veriblock Pool API Scraper** Grafana-APIScraper-InfluxDB.ps1
Scrape a list of public mining pools API data, and collect it to influxDB for Grafana Dashboard reporting and realtime alerts.  This dashboard alerted miners to pools increasing fees, pools getting stuck on blocks, Pool Version Number, and Collective hashrates on the network.  It was a publicly available service for those interested in gaining information about the status and health of the Veriblock mining pool network.  It additionally gathered data from bitcoinfees.earn.com to report the high/low/average BTC fee rates on trading networks.

- **Pinger-Veriblock-Pools.ps1**
Ping the Performance of the current PoolList for Veriblock Pools.  First uses ICMP, and uses Web Port if ICMP is unavailable. (invoke-webrequest)

- **Migrate-NodeCore.ps1**
Write a NodeCore migrations script (Windows)
Copies Nodecore wallet, PoP files, blockchain to latest version
Instead of migrating-we copy- rather than delete older sensitive data

- **Install-NodeCore.ps1**
Install NodeCore in the most automated fashion.  (windows)
Checks to see if the prerequisites are met (Java), downloads, installs, and launches nodecore.

# Gaming

- Check if a game is responding.  This example uses Outriders.


```(Get-Process Madness-WinGDK-Shipping).Responding```

- **Steam Server launcher with password** 

Launch a steam game with the server password copied to clipboard.  You can more easily enter the server by CTRL+V pasting the password when automatically joining.  This example uses Valheim as an example (892970)

```
Start-Process "C:\Program Files (x86)\Steam\steam.exe" -ArgumentList "-applaunch 892970 +connect valheim.server.com:2456"

Set-Clipboard "P@$$w0rd"
```

- **NoMansSky / SaveGameSaver-NoPermaDeath.ps1**

This program will run, and wait for No Man's Sky to start.  Once it starts it will default to backing up the save files every 15m.  This is useful when running a Hardcore / PermaDeath save file.  Especially when the game glitches or you end up dying in some way that was not your fault.  You can now restore one of the previous save files to restore your hardcore game save.  I did not end up needing this to make it to the core, but it was great peace of mind knowning that I would not waste tens of hours on the attempt if I died.
