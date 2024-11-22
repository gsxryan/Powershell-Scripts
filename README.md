# Files

## SCCM / MECM Misc Scripts
 - **CI-JavaExceptionSites.ps1**
 The following STIG may be applied to your enterprise, preventing your users from adding Java site exceptions to their local java clients to run unsigned Java code.  https://www.stigviewer.com/stig/java_runtime_environment_jre_version_7_windows_7/2015-12-10/finding/V-32828
 This script ensures the website is in each machine's local Java Exception sites. PLEASE avoid using this method if at all possible.  It can open your company up to MITM attacks with malicious code injection.  If your developers are unable to sign their Java code, or the vendor cannot sign their code then this CI can be deployed to the Desktops that require access to the Java site.  
 Another alternative may be to package these applications into remote sandboxes such as Citrix or Azure Virtual Desktop.  Or, to package a portable JAR file with the Java Application deployment (See Java below for an example application for this method).  The intention of this script should only be to temporarily mitigate access while a better solution is developed.

## Windows Operations
### For Windows Server Administrators, Tier 2 Help Desk, etc

 - **KeepAlive.ps1**
A technician keeps getting logged out of their remote session while installing an application that takes a very long time to complete (hours).  Application owners have not invested in developing a silent installer distributed by the enterprise.  Disconnect and Logout policies exist for inactivity that the technician cannot modify.  The installation process does not count as user activity.  Technician must attend to the machine manually, and remember to make some kind of activity on the remote session once every 14 mins while waiting.  This can often result in logged out sessions, requiring the installers to restart from the beginning.  This wastes time and negatively effects the teams KPIs.  Running this script on the remote machine allows the technician to ignore the machine during the install process, and is able to start on another customer simultaneously.  This greatly increases the effectiveness of their team.

 - **PsExec-SCCMRemoteInstall.ps1**
 I would recommend looking into Ansible for standardizing operations automation tasks like this. Specifically for SCCM, utilize the builtin tools unless attempts have already failed.  You may have a use case needing to quickly resolve a software deployment project without as much oversight needed.  This is specific to installing SCCM Client on remote machines without having to RDP into each machine.  However, the batch files executed could be swapped out to remotely deploy with PsExec on any other silently installed applications.  The only dependencies assume you have PSEXEC.exe already downloaded to the current working directory, you are an administrator on the remote machines, and policy allows PSEXEC to run.  Modern threat agents may assume suspicious behavior from PSEXEC, so utilizing your enterprise standard remote deployment tools is recommended.

 - **Misc**
 Get Health of machines Registry.pol to detect for potential compliance health issues
 ```(Get-Content -Encoding Byte -Path \\$hostname\c$\Windows\System32\GroupPolicy\Machine\Registry.pol -TotalCount 4)```

## InfoSec
- **LastActivityCheck.ps1**
Run a timer that resets when keyboard or mouse input is detected.  Hunt for stealthy mouse jigglers, or scroll lock spammers built in to conference kiosks.  Additionally, continuous logging could be built into this as a persistent service to detect if there is a consistent activity on a schedule.  
Ex: the mouse jiggles every 3m.  You will be able to see history of device activity every 3m.
https://www.stigviewer.com/stig/microsoft_windows_11/2022-06-24/finding/V-253297

- **UserLoginUptime.ps1**
Runs during the users logged in session.  It will continue to count time as soon as it starts.  This can be useful when testing or troubleshooting the session logoff policy delay in remote sessions.  
Ex: the session may disconnect, but leave the user logged in.  After re-establishing the connection, you can detect the time the session was idle, disconnected without having been logged out.
https://www.stigviewer.com/stig/windows_server_2012_2012_r2_member_server/2015-06-26/finding/V-3458

# Active Directory

Some of the functions used in scripts have been broken down here in the readme to not get too specific about how you want to gather input or export results.
This can be useful when generating phased test rings in a staged software deployment strategy.

-Get-ADUser
Get users that contain a specific physical office designation.  
```get-aduser -LDAPFilter "(physicaldeliveryofficename=CONTOSO/SITE/DIV/OFFICE)" | select GivenName, Surname, SamAccountName```

-Get-ADComputer
Get computers in AD that match a particular OU property.
```(Get-ADComputer $hostname | where {$.DistingushedName -match "Accounting"}).DistinguishedName```

-Get-ADOrganizationalUnit
Get computers in AD that match an exact OU path
```$list = (Get-ADOrganizationalUnit -SearchBase "ou=exempt,ou=instruments,dc=rcautomate,dc=com" -Filter *).DistinguishedName```
select only the objects that are enabled
``` foreach ($pc in $list) {$advlist = += (get-adcomputer -Searchbase "$pc" -Properties -Name -Filter * | Where-Object {$_.Enabled -eq $true}).Name}```
sort and dedupe
``` $advlist | Sort-Object | Select-Object -Unique```

# Crypto

## Burstcoin (dead)
- **burstcoin-filename-textfile.ps1** 
    List the filenames in each drive, and output them to a text file.

## Veriblock (unlisted)

- **Veriblock PoolList**
Maintain a list of currently mined pools. (archived)
https://gist.github.com/gsxryan/c8de9faf79a7f29bb96d925702096023

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