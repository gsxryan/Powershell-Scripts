:: Step 2, Admin can install now with guided assistance
:: Install SAS Using Zipped file to improve deployment speed and performance
:: One Click BAT file for T2 admins

SET PSPath=%~dp0Admin-SASOptimizedCacheInstall.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PSPath%'";