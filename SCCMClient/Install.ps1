Read-Host "Press Enter to install SCCM Client"

xcopy "\\fileserver\folder\ccmsetup.exe" C:\temp\ccmsetup.exe

CD C:\Temp\

Start-Process ".\ccmsetup.exe" -ArgumentList "SMSSITECODE=PS1 mp=mp.server"

Write-Host "Waiting for SCCM Client completion..."
Write-Host "Waiting 4mins to check logs"

sleep 240

Get-ChildItem "C:\Windows\ccmsetup\Logs\client.msi.log" | Select-String "Windows Installer installed the product. Product Name: Configuration Manager Client*"
Get-ChildItem "C:\Windows\ccmsetup\Logs\client.msi.log" -wait | Select-String "Windows Installer installed the product. Product Name: Configuration Manager Client*"

Read-Host "Press Enter to Exit"