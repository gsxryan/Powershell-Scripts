# RCautomate.com

# PSEXEC deployer Script
# Mimicks SCCM or Ansible to deploy software or scripts utilizing PSEXEC

# Uncomment a value to select a list of servers to deploy to
# The intent of having multiple lines with different lists is to deploy in a careful staged manner.
# This allows a moment to gather data, feedback and testing before deploying to a larger userbase.
# Ring 1 (smallest), Ring 2 (smaller), Ring 3 (small), Prod Auto Patch, Prod Manual Patch

#Ring 1 (Dev)
$serverlist = "RCVMAPPDEV1", "RCVMAPPDEV2"
#Ring 2 (Test)
#Ring 3 (Pre-Production)
#Prod Auto (Production)
#Prod Manual (Crown Jewel Production)

foreach ($server in $serverlist){
#Is the server online/active? Ping it, if not, stop.
$Ping = (Test-Connection $server -Count 1 -ErrorAction SilentlyContinue).ResponseTime 

If ($null -ne $Ping)
{
#Copy to local machine
xcopy C:\temp\appsource\* \\$server\c$\temp\appdest\*

#Run on local machine
.\PsExec.exe \\$server C:\temp\appdest\install.bat

#look for success, this is dependent on the specific application output - WILL NEED REVIEW
$success = Select-String "Installation completed successfully." '\\$server\c$\Program Files\Logs\install.log'

if($null -eq $success)
{Write-Host "$server has FAILED to install!"}
else {
    Write-Host "$server is SUCCESSFULLY INSTALLED."
    #cleanup local files
    Remove-Item \\$server\c$\temp\appdest -Force -Recurse
}

$Ping = $null
}
else {
    Write-Host "$server is OFFLINE!"
}
}


