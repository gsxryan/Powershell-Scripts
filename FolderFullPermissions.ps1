
# RCautomate.com forked Script from jonathanmedd
# MJ Added Function Passing for Multiple folders

#This is a test to see if VSCode has permissions to update itself within a portable installed path C:\Applications

#Get the username to add full control for C:\Applications
$User = $env:USERNAME

# Article on Powershell functions on powershell functions
# https://www.jonathanmedd.net/2015/01/how-to-make-use-of-functions-in-powershell.html

function Fix-Folder-Perms {

Param ([String]$FolderPath)

# $FolderPath = "C:\Applications"
Write-Output "Working on $($FolderPath)"

#Get current folder properties
$acl = Get-Acl $FolderPath

#Keep inheritance (False), Apply to all child files and folders (True)
#To get rid of inheritance use True, ?
$acl.SetAccessRuleProtection($False, $True)

#$acl.Access | % { $acl.RemoveAccessRule($_) } # remove all security, LAST resort only

#Give your user account full control on C:\Applications and all subfolders & Files
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule($User, 'FullControl',  'ObjectInherit, ContainerInherit', 'None', 'Allow') # I set my admin account as also having access
$acl.AddAccessRule($rule)
(Get-Item $FolderPath).SetAccessControl($acl)

}

Fix-Folder-Perms -FolderPath "C:\Applications"
Fix-Folder-Perms -FolderPath "C:\Users\$($User)\.vscode"
Fix-Folder-Perms -FolderPath "C:\Users\$($User)\AppData\Roaming\Code"
Fix-Folder-Perms -FolderPath "C:\Users\$($User)\AppData\Roaming\Notepad++"
