# RCautomate.com
# Copying prestaged licenses on a fileshare

New-Item -ItemType directory -Force -Path "C:\ProgramData\DNASTAR\Licenses"
New-Item -ItemType directory -Force -Path "C:\ProgramData\DNASTAR\DataManager"
Copy-Item "\\fileshare01\DNAStar\ContosoLicense\*" -Destination "C:\ProgramData\DNASTAR\Licenses"
