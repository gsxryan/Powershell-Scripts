<#

Monitor FlexLM for license status
Take action if service is unhealthy
Advanced License query tool reference: https://github.com/f0oster/License-Server-Query-Tool/blob/main/FlexLicenseExample.ps1

Use a windows scheduled task to run as desired.

Optimally, schedule after monthly maintenance before customers return.
Appendix:

orglab: Origin Labs 2018 and lower - OLicense.lic required from vendor.
use_server.lic contents:
----
SERVER LICServer01.contoso.com ANY
USE_SERVER
----
Location: C:\Program Files\OriginLab\Origin YYYY MSI

DNAStar
Location: C:\ProgramData\DNASTAR\Licenses

adskflex: Autodesk / RevIt suite

Healthy state text:
$Servername: license server UP (MASTER)
orglab: UP
adskflex: UP
#>

$LMServer = 'SERVERNAME'
$RMSServer = 'SERVERNAME'
$LMUtilPath = 'C:\Autodesk\Network License Manager'
$RMSUtilPath = 'C:\Program Files (x86)\DNASTAR-LicenseServer\Admin'
$LMState = & $LMUtilPath\lmutil.exe lmstat
$RMSstate = & $RMSUtilPath\lsmon.exe $RMSServer
$LMApps = 'orglab, adskflex'
$RMSApps = 'MegAlign'

#If you detect UP state for each app, do nothing.
#Else, email the DL that the application is down

# FlexLM / Sentinel RMS MASS Client License Updater
# Also can be used as generic folder comparison. 
# For network shared folder, clone to client (like RCLONE / robocopy /MIR, except more precise about making any changes, and ability to more easily target batch list of machines
# Run as admin / SYSTEM
# RCAutomate.com

 <#
# This script will save Help Desk teams approx 30 mins - 1hr per installation of manual configuration with users.
# For example: an environment with about 100 client installs, should save approx 50-100 hours of manual labor.
# Systems owners did not coordinate modernization; Operations teams are pressed to find an alternative way to move these services to comply with server EOL.

This will contact a centralized server resource to detect latest *.lic files.
Compare them to each client endpoint if they don't match update the client license file.
This will force clients to use a standard/new license server.

This assumes clients are already configured to use a network license.
There may be additional steps needed if you're converting from an individually provisioned / non networked license install.
As such, it's only recommended to deploy this to known network configured clients until further testing is done.

The source folder should contain only the files you wish to target for comparison / update on the client.
#>

Start-Transcript C:\temp\FlexLMupdater.log

$SourcePaths = @(Origin2018\License,` #One File
AutoDesk2018\License,` #One File
DNAStar\License) #Many files

# Pair to above source path, incremented based on order [Origin, Autodesk, DNAstar, etc]
# use UNC Path format, \\hostname will generate in the script below

$DestinationPaths = @("C$\ProgramData\OriginLab\License",` #USE_SERVER.lic
"C$\ProgramData\Autodesk\CLM\LGS\765J1_2018.0.0.F",` #LICPATH.lic
"C$\ProgramData\DNASTAR\Licenses") #Many files

#Request a list of machines to check
#$hostname = Read-Host "What is the machine name to check?" #Test Mode
# MECM: $hostname = $env:COMPUTERNAME
# Batch Script: Import GUI popup to paste list of hostnames

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Computername List'
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(100,220)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(200,220)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel

$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter the computerlist below:'

$form.Controls.Add($label)
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,150)

# Set the Multiline property to true.
    $textBox.Multiline = $true
#Add vertical scroll bars to the TextBox control.
    $textBox.ScrollBars = "Vertical"
#Allow the ENTER key to be entered in the TextBox control.
    $textBox.AcceptsReturn = $true
#Allow the TAB key to be entered in the TextBox control.
    $textBox.AcceptsTab = $true
#Set WordWrap to true to allow text to wrap to the next line.
    $textBox.WordWrap = $true
#Set the default text of the control.
    $textBox.Text = "HOSTNAME" #Default input on popup
$form.Controls.Add($textBox)

 

$form.Topmost = $true

 

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)

{

    $x = $textBox.Lines

    #split the data into an array by RETURN Key

    $x = $x.Split("`r")

    #IF that doesn't catch anything, split it by spaces.

         if ($x.Count -lt 2)

            { $x = $x.Split(" ")

    #eliminate any remaining spaces

    $x = $x.replace(' ','""')

}

}

 

foreach ($hostname in $x)

{

#Check if the file exist on the clients submitted
#for each source path
#$arraycount = $SourcePaths.count

$i=0

foreach ($source in $SourcePaths)

{  

    #get a list of all files on the webserver source

    $serverfiles = (Get-ChildItem $source -ErrorAction Silent).name

    if($null -eq $serverfiles) {Write-Host "No files to verify in server $source. Ask admin to update server source."}

 

    #If there are files in source, verify they are updated to client

    #This will not launch if there are no files on the clients to compare

    foreach ($file in $serverfiles)

    { 

        # $DestinationPaths[0] has issues passing in Write-Host, make it easier to call

        $Destination = $DestinationPaths[$i]

 

        #get a list of all files on the client path destination

        $clientfiles = (Get-ChildItem \\$hostname\$Destination -ErrorAction Silent).name

        # If the client contains files to compare, continue this for loop

        if ($null -ne $clientfiles)

         {

        #verify the hash matches for each of them on the client

        $SourceFile = Get-FileHash $source\$file -Algorithm SHA256

        $DestinationFile = Get-FileHash \\$hostname\$Destination\$file -Algorithm SHA256

 

        #If the hashes don't match, copy the file from the server.

            if ($SourceFile -ne $DestinationFile)

             {

                # Copy-Item -Path "$source\$file" -Destination \\$hostname\$Destination\$file # Uncomment when ready to make live changes [-force may be required if validation fails]

                Write-Host \\$hostname\$Destination\$file updated!

 

                # file verification after changes

                $DestinationFile = Get-FileHash \\$hostname\$Destination\$file -Algorithm SHA256

                if ($SourceFile -ne $DestinationFile)

                    {Write-Host "Verification FAILED! do you have permissions to?: \\$hostname\$Destination\$file"}

            }

             else {Write-Host "$source\$file skipped, already updated."}

        #If the hash matches, continue and ignore, report file unchanged

            }

 

        # If there are no files to compare existing on the client, skip this source.

        else {write-host "No files in \\$hostname\$Destination to compare, skipping"}

    }

    #increment the Destination path the follow the order in the arrays above.

    $i++

}

 

}  #comment to stop the batch hostname request

Stop-Transcript