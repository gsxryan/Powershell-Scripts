<# Aperio eSlideManager Database User Audit code
Define count and status of all Aperio user accounts in the database for auditing.

RCautomate.com

SQL QUERIES USED
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS TotalUsers FROM [aperio].[Core].[Users]" -ServerInstance .
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS InactiveUsers FROM [aperio].[Core].[Users] WHERE [Inactive] = 1" -ServerInstance .
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS ActiveUsers FROM [aperio].[Core].[Users] WHERE [Inactive] = 0" -ServerInstance .
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS NULLUsers FROM [aperio].[Core].[Users] WHERE [Inactive] IS NULL" -ServerInstance .
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS ActiveAdmins FROM [aperio].[Core].[Users] WHERE [AdminUser] = 1 AND [Inactive] = 0" -ServerInstance .
Invoke-Sqlcmd -Query "SELECT COUNT([Id]) AS InactiveAdmins FROM [aperio].[Core].[Users] WHERE [AdminUser] = 1 AND [Inactive] = 1" -ServerInstance .

Default admin account: AperioSVC, or Give your account SQL permissions to /aperio database
#>

#Set variable Date/Time, format for using in file name, and set report path.

$CurrentDate = Get-Date
$CurrentDate = $CurrentDate.ToString('yyyyMMdd')

$csvfilename = "c:\Reports\" + $CurrentDate + "_AperioUsers.csv"


$UserTable = Invoke-Sqlcmd -Query "SELECT [Id],[LoginName],[AdminUser],[LastLoginTime],[SuccessiveInvalidLogins],[LastPasswordChange],[AccountCreateDate],[Inactive],[LastUsedRoleId],[CreatedBy] AS UserTable FROM [aperio].[Core].[Users] ORDER BY [LastLoginTime]" -ServerInstance .
$TotalUsers = $UserTable.Count
$InactiveUsers = ($UserTable | ? {$_.Inactive -eq 1}).count #$usertable count where Inactive = 1
$ActiveUsers = ($UserTable | ? {$_.Inactive -eq 0}).count #$usertable count where Inactive = 0
$NULLUsers = ($UserTable | ? {$_.Inactive -eq $null}).count #$usertable count where Inactive = NULL
$ActiveAdmins = ($UserTable | ? {$_.AdminUser -eq 1} | ? {$_.Inactive -eq 0}).count #$usertable count where [AdminUser] = 1 AND [Inactive] = 0
$InactiveAdmins = ($UserTable | ? {$_.AdminUser -eq 1} | ? {$_.Inactive -eq 1}).count #$usertable count where [AdminUser] = 1 AND [Inactive] = 0
$AdminUsrSysAd = @($UserTable | ? {$_.AdminUser -eq 1} | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 1})
$AdminUsrRootAd = @($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 103})
#Locked Admins $AdminUsrLocked = @($UserTable | ? {$_.Inactive -eq 1} | ? {$_.LastUsedRoleId -eq 1})
$AdminALL = @($AdminUsrSysAd).count + @($AdminUsrRootAd).count

# Custom Group definitions, these may be unique to each install.
$UsrPrincInves = @($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 102}).count
$UsrPathologist = @($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 100}).count #Pathologist group 100

#Unused Accounts
$UnusedAccounts = @($UserTable | ? {$_.Inactive -eq 0} | ? {[String]::IsNullOrEmpty($_.LastUsedRoleId)})
$UnusedAccountct = $UnusedAccounts.Count

$TotalActiveUsers = ($UnusedAccounts.Count) + $UsrPrincInves + $UsrPathologist

#SUMMARY
$UserHeader =  "`"ActiveAdmins`",`"ActiveUsers`",`"UnusedActive`",`"Inactive`",`"NULL`""
$UserValues = "`"$AdminALL`",`"$TotalActiveUsers`",`"$UnusedAccountct`",`"$InactiveUsers`",`"$NULLUsers`""

-join $UserHeader, $UserValues | Out-File $csvfilename

#Active User SysAdmins
echo "`"-`"," >> $csvfilename
echo "`"SysAdmins group`"" >> $csvfilename
@($UserTable | ? {$_.AdminUser -eq 1} | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 1}) | Select-Object LoginName, LastLoginTime, LastUsedRoleId | ConvertTo-Csv -NoTypeInformation >> $csvfilename
echo "`"RootAdmins group`"" >> $csvfilename
@($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 103}) | Select-Object LoginName, LastLoginTime, LastUsedRoleId | ConvertTo-Csv -NoTypeInformation >> $csvfilename
echo "`"User Principle Investigators`"" >> $csvfilename
@($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 102}) | Select-Object LoginName, LastLoginTime, LastUsedRoleId | ConvertTo-Csv -NoTypeInformation >> $csvfilename
echo "`"User Pathologist`"" >> $csvfilename
@($UserTable | ? {$_.Inactive -eq 0} | ? {$_.LastUsedRoleId -eq 100}) | Select-Object LoginName, LastLoginTime, LastUsedRoleId | ConvertTo-Csv -NoTypeInformation >> $csvfilename
echo "`"Unused Active Accounts`"" >> $csvfilename
@($UserTable | ? {$_.Inactive -eq 0} | ? {[String]::IsNullOrEmpty($_.LastUsedRoleId)}) | Select-Object LoginName, AccountCreateDate | ConvertTo-Csv -NoTypeInformation >> $csvfilename

Import-Csv $csvfilename | ConvertTo-Html -Head $css -Body "<h1>Aperio Database Users Report</h1>`n<h5>Generated on $(Get-Date) Total Users = $TotalUsers</h5>"
#Create Cascading Style Sheets to spice things up
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$htmlfilename = "c:\Reports\" + $CurrentDate + "AperioUsers.html"

Import-CSV $csvfilename | ConvertTo-Html -Head $css -Body "<h1>Aperio Database Users Report</h1>`n<h5>Generated on $(Get-Date) Total Users = $TotalUsers</h5>" | Out-File $htmlfilename -Force

$Body = Get-content ($htmlfilename)
        
$MultipleRecipients = ("recipient1@contoso.com", "recipient2@contoso.com")
Send-MailMessage -to $MultipleRecipients -Subject 'Aperio Users Report' -from AperioUsers@ESM.contoso.com -Body "$Body" -BodyAsHtml -smtpserver 'smtp.contoso.com'