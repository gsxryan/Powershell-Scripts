# Files

- UserLoginUptime.ps1
This script will run during the users login session.  It will continue to count time as soon as it starts.  This can be useful when testing or troubleshooting the session logoff policy delay.

# Active Directory/

Some of the functions used in scripts have been broken down here in the readme to not get too specific about how you want to gather input or export results.

-Get-ADUser
Get users that contain a specific phyical office designation.
```get-aduser -LDAPFilter "(physicaldeliveryofficename=CONTOSO/SITE/DIV/OFFICE)" | select GivenName, Surname, SamAccountName```

-Get-ADComputer
Get computers in AD that match a particular OU property
(Get-ADComputer $hostname | where {$.DistingushedName -match "Accounting"}).DistinguishedName

# Veriblock/

- Veriblock PoolList
Maintain a list of currently mined pools.
https://gist.github.com/gsxryan/c8de9faf79a7f29bb96d925702096023

- Pinger-Veriblock-Pools.ps1
Ping the Performance of the current PoolList for Veriblock Pools.  First uses ICMP, and uses Web Port if ICMP is unavailable. (invoke-webrequest)


- Migrate-NodeCore.ps1
Write a NodeCore migrations script (Windows)
Copies Nodecore wallet, popfiles, blockchain to latest version
Instead of migrating-we copy- rather than delete older sensitive data

- Install-NodeCore.ps1
Install NodeCore in the most automated fasion.  (windows)
Checks to see if the prerequisites are met, downloads, installs, and launches nodecore.
