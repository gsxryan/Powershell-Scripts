#Sync Main Zip file with remote share site for Faster installations

$ZIPName = "SAS_9_4_M7.zip"
$ZIPPath = "\\MAINfileshare.contoso.com\SAS\$ZIPName"
$REMOTEPath = "\\REMOTEfileshare.contoso.com\$ZIPName"

$REMOTEHash = (Get-Item $REMOTEPath).Length/1KB
$sourceHash = (Get-Item $ZIPPath).Length/1KB

#Remote matches Main?, then stop
If (($REMOTEHash -eq $sourceHash) -and ($null -ne $REMOTEHash))
{ Write-Host "Remote share is synced with Main - No Changes Needed!" -ForegroundColor Green }
#If Remote gets outdated, send a warning, but just continue anyway with Main for now
    else 
{
    Write-Warning -Message "Remote share is Outdated Attempting to Sync now" -Verbose
    Start-BitsTransfer -Source "$ZIPPath" -Destination "$InstallPath" -DisplayName "SASzip" -RetryInterval 60 -TransferType Download -Priority High -ErrorAction Stop  #-TransferPolicy Unrestricted
}
