:: Install SigmaPlot 14.5
:: RCAutomate.com

@ECHO OFF
  SETLOCAL
  SETLOCAL ENABLEEXTENSIONS
:: @cd /d "%~dp0"
SET _MSI="%~dp0SigmaplotInstaller.msi"
SET _REDIST="%~dp0vcredist_x86.EXE /Q"

CLS

TITLE Install SigmaPlot 14.5
::/ Setting Environment

:: Uninstall Sigmaplot 13
ECHO [%time%-%date%] Uninstalling Sigmaplot13
msiexec /x {88B90FF3-D0D3-454A-AACE-9B026E2829E3} /quiet /norestart

:: Install Prerequisite Redistributables VC 2013 x86 12.0.21005
::%_REDIST% - invalid path in UNC
ECHO [%time%-%date%] Installing Dependency - VC Redistributables
cmd /c start "" "%~dp0vcredist_x86.exe" /Q 

ECHO [%time%-%date%] Waiting 30 seconds... If we interrupt too early there may be prompt for another installer running, click retry.
timeout 30
:: Install Sigmaplot145

ECHO [%time%-%date%] Closing Excel
taskkill /IM "excel.exe" /F

:: ECHO [%time%-%date%] Copy Installer Local MSI Not supportive of dynamic paths
:: xcopy SigmaplotInstaller.msi C:\temp\SigmaplotInstaller.msi*

ECHO [%time%-%date%] Installing Sigmaplot 14.5
msiexec /i %_MSI% CMDLINE="SILENT=TRUE ALLUSERS=TRUE USERNAME=User SERIALNUMBER=123456789 INSTALLPATH=$PROGRAMFILES$Sigmaplot\SPW14" /l*v "C:\temp\Sigmaplot145.log"

ECHO [%time%-%date%] Do not close this window. It will close when the install is finished.

ECHO [%time%-%date%] Installed Sigmaplot 14.5

ECHO [%time%-%date%] Installing License to all Current and future user profiles

SET PSPath=%~dp0SigmaplotALLusersLicense.ps1
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '%PSPath%'";

:_DONE
ENDLOCAL
EXIT