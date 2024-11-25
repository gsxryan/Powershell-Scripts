 #RCautomate.com
# Open a shortcut link, modify the destination to the specified target path.
# In this example, a shorcut path is modified to launch a remote script with powershell.

$sourcepath = C:\Users\$env:USERNAME\Desktop\Apps\Shortcut.lnk
$destination = C:\Users\$env:USERNAME\Desktop\Apps\Modified\Shortcut.lnk

Copy-Item $sourcepath $destination  ## Get the lnk we want to use as a template
$shell = New-Object -COM WScript.Shell
$shortcut = $shell.CreateShortcut($destination)  ## Open the lnk
$shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -executionpolicy bypass -windowstyle hidden \\fileserver01\scripts\launch.ps1"  ## Make changes
$shortcut.Save()  ## Save