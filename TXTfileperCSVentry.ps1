#Get the CSV File and a specific Column Name
$HostName = import-csv \\Path\to\SCCMlist.csv | Select-Object HN

#for each cell populated in that column, create a $value.txt file
foreach ($host in $HostName)
    {
        Write-Host $hostname.txt
        }