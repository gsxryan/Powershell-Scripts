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
