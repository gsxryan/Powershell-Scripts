<# RCautomate.com
This script will gather a list of usernames in folders.  These usernames match the AD Username, and contain home directory data mapped to each user.
The goal is to identify all the user folders which no longer have an active AD user account. 
These users will be identified for data archival to move off of hot storage.
#>

$Path = "Y:"

# Get Foldernames where usernames are
$foldernames = (Get-ChildItem $path).Name

#Get all AD Homepath
$ActiveADAccounts = Get-ADUser -Filter * -SearchBase "dc=contoso,dc=com" -Properties Name, homedirectory | Where-Object {$_.Enabled -eq "True" -and $_.homedirectory -match "fileserver01"<# -and $_.DistinguishedName -notmatch "DIVISION"#>} | select name, homedirectory
#CANCEL cut out the prefix path - At this point we're not concerned about mismatched homedir, since we know those are correct (if fileserver01)
#now you have raw homedirectory paths for all AD users, this path is assumed to be in a unc path format
$Test=$ActiveADAccounts
#trims the UNC path prefix (e.g., \\fileserver01\home\) from the homedirectory values to isolate just the folder names.
$Homepaths = $test.homedirectory -replace "`\`\`\`\fileserver01`\`\home`\`\", ""

foreach ($user in $foldernames)
{
    #detect if the user has files in the path, if so, continue
$folderpopulated = Get-ChildItem $path\$user
if ($user){
echo "$user has files, comparing..."
#the folder has files, so continue
#Those foldernames must match in AD Homepath
#compare with foldernames - show the diff
if ($Homepaths -notcontains "$user")
{ echo "$User folder is not in AD"
}
#Test Scripts, uncomment the method you'd like to use
#Compare-Object $user "$ActiveADAccounts.name" <#-property Thumbprint, FriendlyName, Subject, NotAfter | Format-Table#>
#Compare-Object $ActiveADAccounts $user <#-property Thumbprint, FriendlyName, Subject, NotAfter#> | Format-Table
#pause
}
}