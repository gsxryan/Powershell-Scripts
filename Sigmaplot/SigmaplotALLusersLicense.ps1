# RCautomate.com - Sigmaplot 14.5 (and below) license installer
#This Installs license to all existing users that have accounts on a single machine
#Also ensures each new user that logs in gets the current license registration.
#Utilizing ActiveSync registry to install the license on new user logins so they will also have access to Sigmaplot.
#Without these mitigations T2 support will need to reinstall the sigmaplot license and enter custom information for each unique user where Sigmaplot is installed.
#This is considered needlessly burdensome, and this script mitigates that requirement from the vendor.

#Increment the version number if you'd like changes to this script to be deployed to each user on next login.
$CurrentVersion = "1"

Start-Transcript C:\temp\Sigmaplot145LicenseInstall.log

#Environment Variables
$CopyLicensePath = "\\fileserver01.contoso.com\Sigmaplot\SigmaplotALLusersLicense.ps1" #This file
$WinAppsPath = "\\fileserver01.contoso.com\Sigmaplot" #if hasp.ini is in a different directory
$ODFolder = "OneDrive" #Change this if you rename client OD folders to "OneDrive - Contoso"
$ToolFolder = "Program Files\Contoso\Tools"

#All historic logged in users on the machine should allocate the license.
#Everything except $CurrentUser Requires admin rights.  If admin rights are not granted it will only do current user, with all other accounts failing.  This is expected.
ForEach ($user in (Get-ChildItem -Name "C:\Users" -Exclude Public, Administrator, NetworkService, bogus, dummy, TempUser, LocalService, Default, "Default User", "All Users")) 
{
New-Item -ItemType Directory -Force -Path "C:\Users\$user\AppData\Local\SafeNet Sentinel\Sentinel LDK"
Copy-Item "$WinAppsPath\hasp_107466.ini" -Destination "C:\Users\$user\AppData\Local\SafeNet Sentinel\Sentinel LDK" -Force

#Set EMS.ini to look at network license, NOT the auto (30 day trial)
#Set EMS.ini to NOT check for updates on startup
$OneDrive = Test-Path "C:\Users\$user\$ODFolder\Documents"
if ($OneDrive -eq $true){
New-Item -ItemType Directory -Force -Path "C:\Users\$user\$ODFolder\Documents\SigmaPlot\SPW14_5"
Copy-Item "$WinAppsPath\ems.ini" -Destination "C:\Users\$user\$ODFolder\Documents\SigmaPlot\SPW14_5" -Force
}
else {
    #If onedrive is not set up create the ini file in Documents, but also in OneDrive to prepare for future profile migration
New-Item -ItemType Directory -Force -Path "C:\Users\$user\$ODFolder\Documents\SigmaPlot\SPW14_5"
Copy-Item "$WinAppsPath\ems.ini" -Destination "C:\Users\$user\$ODFolder\Documents\SigmaPlot\SPW14_5" -Force
Copy-Item "$WinAppsPath\ems.ini" -Destination "C:\Users\$user\Documents\SigmaPlot\SPW14_5" -Force
}

}

Copy-Item "$CopyLicensePath" -Destination "C:\$ToolFolder\SigmaPlotLicense.ps1" -Force

#Persist the license in registry startup, so new users on the machine receive the Sigmaplot license
#This enables Image Deployment team to install Sigmaplot and deliver to the customer, without running the license installation again after the user logs on.

new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\SigmaPlotLicense" -force
new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\SigmaPlotLicense" -name "(Default)" -propertytype String -value "Sigmaplot License Installation" -force
new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\SigmaPlotLicense" -name "StubPath" -propertytype String -value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -ExecutionPolicy bypass -File `"C:\$ToolFolder\SigmaPlotLicense.ps1`"" -force
new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\SigmaPlotLicense" -name "Version" -propertytype String -value "$CurrentVersion" -force

Stop-Transcript