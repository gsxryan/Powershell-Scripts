<# RCautomate.com
Detect if Citrix Workspace is installed
If not, Notify how to install
#>

Function CitrixApp
{
Param ([String]$CitrixLaunchString)

    #Check if Citrix is installed
    $Installed = Test-Path "C:\Program Files (x86)\Citrix\ICA Client\SelfServicePlugin\SelfService.exe"
    #If not, Prompt the user how to install it.
    If ($Installed -eq $false)
    {
        $ishell = New-Object -ComObject Wscript.Shell
        $ishell.Popup("Citrix NOT installed: Opening Software Center so you can install Citrix Workspace App now.  Relaunch this Application after Citrix installation.",0,"Opening Software Center...") > $null
        Start-Process "softwarecenter:"
    }
    else 
    {
        Invoke-Expression $CitrixLaunchString
    }
}

#Test-Line
$CitrixSF = "https://server.contoso.org/Citrix/StoreWeb"
CitrixApp -CitrixLaunchString "Start-Process -FilePath iexplore.exe -ArgumentList `"$CitrixSF`""