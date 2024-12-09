<#  RCautomate.com

Print Device Migration
Must run in User context to migrate the current printers.
    1) Migrate from Old Print Server to New Print Server
        Chose the Same ServerName if you do not wish to perform a migration
    2) Ensure FQDN is used for all new printers mapped

Assumptions
    1) Your migrating print servers share a common prefix
    2) No Local printers are captured, these must be added manually without further script engineering.
    3) DNS cannot be updated as the old server name must continue to be utilized for other services until EOL
#>

Start-Job -Name PrinterMigration -ScriptBlock {

    #On first user login, wait 4 minutes for login to settle
    #This allows the migrated printers to add to the profile before attempting to migrate them.
    #Running immediately during Active Setup is not effective since the printers do not appear in the profile yet.
    Echo "Sleeping four minutes before launch"
    Sleep 240
    
            $PrintServersPrefix = "RCVM"
            $OldPrintServer = "RCVMPRINTERS01"
            $NewPrintServer = "RCVMPRINTERS02"
            $FQDN = ".contoso.com"
            $LogPath = "\\RCVMLOGSERVER.contoso.com\logs\Printers\Data"
            $ErrorPath = "\\RCVMLOGSERVER.contoso.com\logs\Printers\Errors"
    
            Function ExportPrinters
    {
    #get printer
    #Win7 usage:
    [System.Collections.ArrayList]$Printers = get-ciminstance Win32_printer | select name | Where-Object {$_.Name -like "*$PrintServersPrefix*"}
    [System.Collections.ArrayList]$PrintersArray = get-ciminstance Win32_printer | select name | Where-Object {$_.Name -like "*$PrintServersPrefix*"}
    #Win10 Compatibility: [System.Collections.ArrayList]$Printers = get-printer | select name | Where-Object {$_.Name -like "*$PrintServersPrefix*"}
    #Win10 Compatibility: [System.Collections.ArrayList]$PrintersArray = get-printer | select name | Where-Object {$_.Name -like "*$PrintServersPrefix*"}
    
    #convert OldPrintServer to NewPrintServer (with FQDN)
    foreach ($printer in $Printers)
    {
    if($printer -like "*$OldPrintServer*")
    #then replace it with the new print server name
    { 
    $migrate = $printer.name -replace ("$OldPrintServer", "$NewPrintServer$FQDN")
    $PrintersArray.Add($migrate)
    echo "$printer.name converted to $migrate - Complete!"
    Add-Content $LogPath\Master.log "$printer.name, $migrate, $env:username, $env:COMPUTERNAME"
    }
    }
    
    #ensure NewPrintServer contains FQDN
    foreach ($printer in $Printers)
    {
    #if does not contain FQDN, add it
    if(($printer -like "*$NewPrintServer*") -and ($printer -notlike "*$FQDN*"))
    {
    $migrate = $printer.name -replace ("$NewPrintServer", "$NewPrintServer$FQDN")
    $PrintersArray.Add($migrate)
    echo "$printer.name converted to $migrate - Complete!"
    Add-Content $LogPath\Master.log "$printer.name, $migrate, $env:username, $env:COMPUTERNAME"
    }
    #if does already contain FQDN, add it to $PrintersArray
    if(($printer -like "*$NewPrintServer*") -and ($printer -like "*$FQDN*"))
    {
    $migrate = $printer.name
    $PrintersArray.Add($migrate)
    echo "$printer.name converted to $migrate - Complete!"
    Add-Content $LogPath\Master.log "$printer.name, $migrate, $env:username, $env:COMPUTERNAME"
    
    }
    }
    
    #filter out the @{name= garbage records from earlier collections
    $garbage1 = $PrintersArray -like "*$NewPrintServer$FQDN*"
    [System.Collections.ArrayList]$Complete = $garbage1 -notlike "*name=*"
    
    #Dump Results to file for Import use
    $Complete | Out-File $Logpath\$env:username.txt
    echo "File Export to $env:username.txt Complete!"
    }
    
    
    Function DeleteLegacyPrinters
    {
    #get legacy printers
    $LegacyPrinters = (get-ciminstance Win32_printer | select name | Where-Object {$_.Name -like "*$OldPrintServer*"}).name
    
    #delete each LegacyPrinter
    foreach ($LegacyPrinter in $LegacyPrinters)
    {
    Try {
    Remove-Printer -Name $LegacyPrinter
    echo "$LegacyPrinter Deleted."}
    Catch {
    echo "Failed to delete $LegacyPrinter"}
    }
    }
    
    
    Function ImportPrinters
    {
    #Switch Import
    $Import = Get-Content $LogPath\$env:username.txt
    
    foreach ($P in $Import)
    { 
    Try {
        Add-Printer -ConnectionName $P -ErrorAction Stop  #Add Error handling to log undiscovered printers
        echo "$P Complete!"}
    Catch {
        Write-Host "Failed to Import $P.  Verify this printer has been added to $NewPrintServer.  If not, request it." -ForegroundColor Red
        $P | Out-File "$ErrorPath\Errors.txt"}
    }
    }
    
    #Do Everything on the latest Win10 machine, after user state migration tool, logged into the user's account.
    ExportPrinters
    DeleteLegacyPrinters
    ImportPrinters
    
    }