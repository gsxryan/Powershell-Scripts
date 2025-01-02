C:
CD \temp\sas\sas_9_4_M8

echo %username% >> c:\temp\sas\sas_installer.txt

if NOT EXIST "c:\temp\sas\SAS_Install" mkdir "c:\temp\sas\SAS_Install"
third_party\vcredist_x64_2019.exe /install /quiet /norestart
third_party\vcredist_x86_2019.exe /install /quiet /norestart
third_party\ndp48-x86-x64-allos-enu.exe /install /quiet /norestart

start "Requirements Wizard" /wait setup.exe -javaoptions "-Xmx512M" -templocation "c:\temp\sas\SAS_Install" -wait -deploy -noreboot -nomsupdate -loglevel 2 -srwonly -partialprompt -responsefile "c:\temp\sas\sas_9_4_M8\srw_response_M8.txt"