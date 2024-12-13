<# RCautomate.com

From a list of user file directory folders, take each name and scan for inactive accounts
for the account file directories that are inactive, mirror the data to a archive path
for the source path, make sure to delete the data after it's been successfully archived.
This in general is for cleaning up inactive user's home folders on a file share.
It additionally identifies anomalies from home folders that do not match the AD Usernames.
#>
#from a list of users (in this case, a legacy user folders directory)
#find the active accounts in AD
$ActiveADAccounts = Get-ADUser -Filter * -SearchBase "dc=contoso,dc=com" | Where-Object {$_.Enabled -eq "True"} | select Name
$HomeFolders = Get-ChildItem \\fileserver01\users -Name

#Select User Folder Names which are not in ActiveADAccounts Array
$Compare = $HomeFolders | Where-Object {$ActiveADAccounts.name -notcontains $_}
echo $Compare
echo "Total Active User Folders" $HomeFolders.count
echo "Total Inactive User Folders" $Compare.count 

#Added CSV Export to sort by Date last modified to attempt to detect those that do not match the AD-Name, but may be enabled. Export attached

foreach ($item in $Compare)
{

$date = (Get-ChildItem "\\fileserver01\users\$item" -Recurse | sort LastWriteTime | select -last 1).LastWriteTime | get-date -Format d

New-Object -TypeName PSCustomObject -Property @{
Name = $item
Date = $date 
} | Export-Csv -Path test.csv -NoTypeInformation -Append

#echo $item; Get-Date ((Get-Item \\fileserver01\users\$item).LastWriteTime) -Format d

}
<#
Step 1)
                Remove any Recently modified rows from the document above
                Save as a .CSV file where your script can run it
Step 2)
                Run a script to mirror the archive folders to a backup location
                Modify the CSV path below
                Optionally, check the robocopy.log to verify integrity
#>
#RoboCopy Mirror Old Directory, from a list of Names in CSV File
$Archive = Import-Csv Test.csv
$Source = Read-Host "Enter the Source Path (no trailing \)"
$Dest = Read-Host "Enter the destination Path"

Start-Transcript $Dest\RoboCopy.log

clear
Write-Host "This will perform a MIRROR command, be sure your destination is empty"
Write-Host $Dest "(slash all CSV Usernames)"
pause 

foreach ($user in $Archive.name)
{

#robocopy source destination mirror (make sure destination doesn't exist) /Z (restartable mode) 
#/W (wait between retry) /R:4 (only retry 4 times) /fft ( fat file times, legacy beneficial if both volumes are not NTFS)
#  /MT (multithreaded 8x, higher CPU use)
robocopy $Source\$user $dest\$user /MIR /Z /W:1 /R:4 /fft /MT:8

}

Stop-Transcript 
<#
Step 3) 
                Run a script to delete the archived folders
#>
foreach ($user in $Archive.name)
{

#delete each old source folder
Remove-Item -Path $Source\$user -Recurse

}