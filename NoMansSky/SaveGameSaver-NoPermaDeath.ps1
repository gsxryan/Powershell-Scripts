#NMS Permadeath SaveGame Saver
#RCAutomate.com

$BackupPath = "C:\Users\$env:USERNAME\AppData\Roaming\HelloGames\bak"
$GamePath = "C:\Users\$env:USERNAME\AppData\Roaming\HelloGames\NMS"
#GamePath must only have a single folder in it (st_*)
$SaveEvery = 900 #Seconds between each save Default 15m (900)
$KeepHistory = 8 # ($SaveEvery /60) * ($KeepHistory) = Minutes of Backups available
#FEATUREADD: Change to everytime the source directory has a change (new save-immediate backup)

#Give an option (1) Backup (2) Restore
$Mode = Read-Host 'Start Backup Job (1) or Restore (2)?'

If ($Mode -eq 1)
{1
#Does the backup path Exist?
$BackupPathTest = Test-Path $BackupPath
    #If NOT, create it
    If ($BackupPathTest -eq $false)
        {New-Item -ItemType Directory -Path $BackupPath}

#Save Every X mins while NMS.exe is open
#Is NMS open?
$GameState = (Get-Process -ProcessName NMS).ProcessName
If ($GameState -ne $null)
    {
        #get the dynamic foldername
        $foldername = (Get-ChildItem -Path $GamePath\st_*).Name
        #Start Saving the Gamefiles every Xmins
        While ($GameState -ne $null)
        {
        #detect excess backups and cleanup AKA keep a Default, rolling 2 hour history of savegames (8 savegames)
        $BackupQTY = (Get-ChildItem -Directory $BackupPath).count
            If ($BackupQTY -gt $KeepHistory)
            {#Delete the oldest BackupQTY folder
            
            }
        #Get the UNIXDatetime
        $epoch = (Get-Date -Date ((Get-Date).DateTime) -UFormat %s)
        new-item -ItemType Directory "$BackupPath\$epoch\$foldername"
        copy-item -Path "$GamePath\$foldername" -Recurse -Destination "$BackupPath\$epoch\$foldername"
        sleep $SaveEvery
        $GameState = (Get-Process -ProcessName NMS).ProcessName
        }
    }
    else {
        Write-Host "The Game has stopped or is not running, please start the game first and rerun."
    }

}

else {
    #Restore Mode Start
    #INCOMPLETE
}

Write-Host "The Game has stopped.  Stopping Backup jobs..."
pause