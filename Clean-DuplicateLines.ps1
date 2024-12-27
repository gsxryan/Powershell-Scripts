#Scan contents of all files
#export to a new folder with Cleanup and Get only Unique lines in .txt files

$UserTXTFiles = Get-ChildItem \\path\to\txt\files -Name

foreach ($User in $UserTXTFiles)
{
gc $user | sort | get-unique > \\path\to\txt\files\Sorted\$user
}

