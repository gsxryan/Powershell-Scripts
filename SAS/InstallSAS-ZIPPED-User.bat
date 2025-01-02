:: Step 1, Provision local installation cache (user can perform)
:: Install SAS Using Zipped file to improve deployment speed and performance
:: One Click BAT file for users or T2 admins

SET PSPath=%~dp0User-PreStageFilesforAdminInstall.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PSPath%'";