:: Install Application Name version.number RCautomate.com

    SETLOCAL
    SETLOCAL ENABLEEXTENSIONS
CLS

TITLE Install Application version.number
::/ Setting Environment

    SET local_log="C:\Program Files\Contoso\Logs\Application.version_install.log"

:: Install Application Name

ECHO [%time%-%date%] Installing License to machine

SET PSPath="%~dp0DNAStarLicense.ps1"
Powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%PSPath%'";

:: RecSettings.ini assumes you have used the macro capture from the installer to create a config file
ECHO [%time%-%date%] Installing DNAStar 12.3a >%local_log%
    %~dp0DNAStarLasergeneInstaller.exe -p: recsettings.ini

ECHO [%time%-%date%] Do not close this window.  It will close when complete. >>%local_log%

ECHO [%time%-%date%] DNAStar Installed >>%local_log%

:_DONE
pause

ENDLOCAL
EXIT