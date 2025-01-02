IF NOT EXIST "c:\temp\sas" mkdir "c:\temp\sas"

C:
CD \temp\sas

start "Deployment Wizard" /wait setup.exe -javaoptions "-Xmx512M" -loglevel 2 -templocation "c:\temp\sas" -wait -deploy -noreboot -nomsupdate -partialprompt -changesashome -responsefile "c:\temp\sas\sas_9_4_M8\install_response_M8.txt"