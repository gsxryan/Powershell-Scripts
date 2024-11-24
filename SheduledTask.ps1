#RCautomate.com

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' `
  -Argument '-ExecutionPolicy bypass -File \\fileshare.contoso.com\Script.ps1'
$user="Contoso\Username"
$trigger =  New-ScheduledTaskTrigger -Once -At (Get-Date).AddMinutes(1)
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "Script Execution" -Trigger $Trigger -User $User -Action $Action -Settings $Settings -Force

#Remove the Scheduled Task
Get-ScheduledTask | Where-Object {$_.TaskName -match "Script Execution"}| Unregister-ScheduledTask -Confirm:$false