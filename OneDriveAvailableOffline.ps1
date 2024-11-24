#https://community.spiceworks.com/topic/2140825-powershell-script-to-change-onedrive-file-attributes
#https://techcommunity.microsoft.com/t5/microsoft-onedrive-blog/onedrive-files-on-demand-for-the-enterprise/ba-p/117234

#RCautomate.com
#BUG: Subfolders within the chosen directory will not change defaults to desired value, but all the files within directories will.
#Need an enhancement to fix this

#Get Current User
$User = $env:USERNAME

<#
attrib -U +P /s makes a set of files or folders always available
attrib +U -P /s makes a set of files or folders online only
#>

#DEV this below to customize as needed
#Set all Documents folder to be Always Available
get-childitem "C:\users\$User\OneDrive\Documents" -Force -File -Recurse |
Where-Object Attributes -ne "525344" |
ForEach-Object {
    attrib.exe $_.fullname -U +P /s
}

