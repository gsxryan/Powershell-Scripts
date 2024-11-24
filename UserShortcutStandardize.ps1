#RCAutomate.com

#For each user profile on the machine, remove the non-standard, non-managed shortcuts
ForEach ($user in (Get-ChildItem -Name "C:\Users" -Exclude NetworkService, LocalService)) 
{
Remove-Item "C:\Users\$user\Desktop\citrix.lnk"
Remove-Item "C:\Users\$user\Desktop\Citrix Applications.url"
Remove-Item "C:\Users\$user\Desktop\Citrix Applications.lnk"
}

#Remove the shortcut generated on first user login
Remove-Item "C:\Users\Default\Desktop\citrix.lnk"
Remove-Item "C:\Users\Default\Desktop\Citrix Applications.url"
Remove-Item "C:\Users\Default\Desktop\Citrix Applications.lnk"

#Copy the universal managed profile shortcut to all users desktop folder
Copy-Item "\\fileshare01\Citrix Applications.lnk" -Destination "C:\Users\Public\Desktop"