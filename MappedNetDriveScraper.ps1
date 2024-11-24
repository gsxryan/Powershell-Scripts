#RCautomate.com
#Network Drive Scraper

#RunAs anyone on the PC
#DEV: load NTUSER.dat file to crawl all user mapped drive paths.

#RunAs the user
Get-ChildItem -Path "HKCU:Network"
Get-ItemProperty -Path "HKCU:\Network"