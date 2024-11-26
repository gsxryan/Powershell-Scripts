# RCautomate.com
# Compare the Certificates between two machines, export to CSV
# This can be useful to determine certificate or authentication behavioral differences between PCs.
# $computer is assumed to be the current running PC unless otherwise specified.

#Compare these two machines
$HOSTNAME1 = "HOSTNAME1"
$HOSTNAME2 = "HOSTNAME2"

function Get-Certificates {
    Param(
            $Computer = $env:COMPUTERNAME,
            [System.Security.Cryptography.X509Certificates.StoreLocation]$StoreLocation,
            [System.Security.Cryptography.X509Certificates.StoreName]$StoreName
          ) 

    $Store = New-Object System.Security.Cryptography.X509Certificates.X509Store("\\$computer\$StoreName",$StoreLocation)
    $Store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]"ReadOnly")
    $Store.Certificates
}

$Left = Get-Certificates -StoreLocation LocalMachine -StoreName Root -Computer $HOSTNAME1
$Right = Get-Certificates -StoreLocation LocalMachine -StoreName Root -Computer $HOSTNAME2

# Dump to console
Compare-Object $Right $Left -property Thumbprint, FriendlyName, Subject, NotAfter | Format-Table

# Export results to file
#Compare-Object $Left $Right -property Thumbprint, FriendlyName, Subject, NotAfter | Export-Csv Comparison.csv 

