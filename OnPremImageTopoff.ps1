<# RCautomate.com
This use case verifies if the incoming user picking up a PC is a member of any Citrix Groups.
Citrix receiver is not deployed by default, and users have a difficult time installing it on their own.
This assists the technician to verify if the incoming user should have the software installed before they depart the imaging lab
It also assumes SCCM Software Center will need to be opened to pull the software.
This can be replaced by other enterprise supported deployment mechanisms.

Additionally, a custom AD user property is checked to verify if HR has cleared the employee.
If the property is null or invalid, they need to complete actions with HR before being able to login to the PC.
#>

#Which user is receiving the PC?
$User = Read-Host "Who will receive the PC? (use their AD alias)"
$AppServer = "\\fileserver01"

#Check if member is a user of any Citrix Groups in AD that should receive citrix receiver
$ADGroups = @(
'Contoso Application1 Citrix'
'Contoso Application2 Test'
'Contoso Application2 Dev'
'Contoso Application2 Prod'
'Contoso DB Admins'
'Contoso SysAdmins'
)

<#
#DEVNOTE: Reserve for including specific linkaar Shortcut links, not having an AD group for citrix dependency checks


$linkaarlinks = @(
'Application1'
'Application2'
)

Function CheckLinkaarApp
{

#parse through each UserFile to detect if App is missing
$UsersApplist = Get-ChildItem $AppServer\Linkaar\Users\*.txt -Name
#Write-Host if the App is missing

foreach ($UserApp in $UsersApplist)
{
    Write-Host "The following users have $Link"
    $HasApp = Get-Content $AppServer\Linkaar\Users\$UserApp | Select-String ^$AppName`$
if ($HasApp)
{Write-Host "$UserApp"; $i++}
}
Write-Host ""
Write-Host "$i Users have $AppName"
$i=0
}
#>

ForEach ($group in $ADGroups)
{
    $member = Get-ADGroupMember $group
    $membercount = ($member).count
    #Count each individual group
    Write-Host "$membercount` Users in: $group, Checking next group..."

    $memberlist += ($member).name
}

#Total distinct count
Write-Host ""
Write-Host "If the counts above look too high, (including too many people) consider removing the group from this search"
Write-Host "TOTAL Unique user count requiring citrix: " ($memberlist | Select-Object -Unique).count

#Is the user in the list?  If so, install Citrix Workspace App
if ($memberlist -contains $User)
{
    Write-Host ""
    Write-Host "" 
    Write-Host "$User DOES Need Citrix!  Opening Software center now." -ForegroundColor Green
    Start-Process "softwarecenter:"
}
else {
    Write-Host ""
    Write-Host ""
    Write-Host "$User Does NOT Need Citrix.  Carry on!"
}

#DEVNOTE: Is One-Drive Desktop Activated?

Pause
#Check if user has been assigned a specific Contoso ID code
$ADProp = (get-aduser $User -Properties contoso-customidcode)."contoso-customidcode"

If ($null -eq $ADProp)
{
    #User must be referred back to HR offices for provisioning before continuing.  
    Write-Host "ERROR: User doesn't have a Contoso ID Code yet! Have user Contact HR offices for onboarding completion" -ForegroundColor Green
}
else{Write-Host $ADProp}

Pause

#Verify HR platform web status
#Launch http://contoso.com/HRProvisioning.status to search for user
Write-Host "Manual Check HR Status site - Check status to see if user is authorized to login"
Start-Process -FilePath "iexplore.exe" -ArgumentList "http://contoso.com/HRProvisioning.status"
