# Action will occur on each users' first login on the machine
    # The SCCM Detection method can be setup to use this version number.  If the current version number in HKLM is less than current (in users HKCU), the script will re-deploy.  Each user, upon next login will run the script.
    # During the next deployment, change the version number of the registry entry, and force this will cover all new nonexisting users
    # This runs with the users' permissions only, so use the non-admin scripts.
    
    new-item -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\ScriptName" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\ScriptName" -name "(Default)" -propertytype String -value "Description of ScriptName" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\ScriptName" -name "StubPath" -propertytype String -value "C:\Windows\system32\WindowsPowerShell\v1.0\powershell.exe -windowstyle hidden -ExecutionPolicy bypass -File `"C:\UTILS\ScriptName.ps1`"" -force
    new-itemproperty -path "HKLM:SOFTWARE\Microsoft\Active Setup\Installed Components\ScriptName" -name "Version" -propertytype String -value "1" -force
