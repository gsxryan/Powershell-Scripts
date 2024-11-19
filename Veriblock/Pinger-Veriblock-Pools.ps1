<#
Veriblock Public Pools Pinger
Managed on Github Gist source:
https://gist.github.com/gsxryan/13390725dcadf08b727dc3571743ae0a
Purpose:
Tests each of the current active pools listed on the Dashboard veriblock.turbomypc.com and reports the best ping to your worker
Usage:
powershell.exe -executionpolicy bypass ./Ping-VBPools.ps1
optional
./Ping-VBPools.ps1 Offline (Use for an offline file PoolList.csv by default)
Assumptions:
Assumes pools allow ICMP traffic.  Need to add logic to detect pools that block ICMP, but allow pool port traffic.
Requested Features:
Jake Wiser - miner swaps to lowest ping pool available automatically#>


param([string]$LaunchMode)

switch ("$LaunchMode"){

    Offline {
                $FileTest = Test-Path .\PoolList.csv
                if ($FileTest -eq 1)
                {$PoolList = Get-Content .\PoolList.csv}
                else
                {$PoolFile = Read-Host "Enter the Filename"
                $PoolList = Get-Content .\$PoolFile | ConvertFrom-Csv}
                
            }
    Default {
                $LivePools = (Invoke-WebRequest https://gist.githubusercontent.com/gsxryan/c8de9faf79a7f29bb96d925702096023/raw/VeriBlockPoolList.txt).content
                $PoolList = ConvertFrom-Csv $LivePools
            }

    }

#Define a Table to use to output readable data
$table = New-Object system.Data.DataTable "Veriblock Pool Pings"
$col1 = New-Object system.Data.DataColumn PoolAddr,([string])
$col2 = New-Object system.Data.DataColumn Ping,([string])
$col3 = New-Object system.Data.DataColumn PoolName,([string])
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)

$table2 = New-Object system.Data.DataTable "Veriblock API Pings"
$col21 = New-Object system.Data.DataColumn PoolAddr2,([string])
$col22 = New-Object system.Data.DataColumn APIPing,([string])
$col23 = New-Object system.Data.DataColumn PoolName2,([string])
$table2.columns.add($col21)
$table2.columns.add($col22)
$table2.columns.add($col23)

#Ping Each Pool, If Pingable, probe the pool port and output results to table
foreach ($pool in $PoolList) {
$PoolName = $pool.Name
$PoolAddress = $pool.address
$PoolPort = $pool.Port

$Ping = (Test-Connection $PoolAddress -Count 1 -ErrorAction SilentlyContinue).ResponseTime

$APIping = (Measure-Command{Invoke-WebRequest -Uri "http`:`/`/$PoolAddress`:8500" -ErrorAction SilentlyContinue -TimeoutSec 2}).Milliseconds
$Port = (Test-NetConnection $PoolAddress -Port $PoolPort -ErrorAction SilentlyContinue -WarningAction SilentlyContinue).TCPTestSucceeded

if($Port)
{Write-Host $PoolAddress "is UP. Ping is" $Ping "ms"
$row = $table.NewRow()
$row.PoolAddr = $PoolAddress
$row.Ping = $Ping
$row.PoolName  = $PoolName
$table.Rows.Add($row)
$Port = $null
}

else {Write-Host "Port" $PoolPort "CLOSED on" $PoolAddress ", see the API response instead..."}

if($APIping)
{Write-Host $PoolAddress " API is UP. Ping is" $APIping "ms"
$row2 = $table2.NewRow()
$row2.PoolAddr2 = $PoolAddress
$row2.APIPing = $APIping
$row2.PoolName2  = $PoolName
$table2.Rows.Add($row2)
$APIping = $null
echo ""
}

else {Write-Host "API Webpage" $PoolAddress "DOWN"}

$Ping = $null

}

echo "API Webpage response"
if ($table2){echo $table2}
#$table = $null
Start-Sleep 2

echo ""
echo "ICMP Response"
echo ""
echo ""

if ($table){echo $table}
#$table2 = $null

Write-Host "For the current pool list, see https://gist.github.com/gsxryan/c8de9faf79a7f29bb96d925702096023"