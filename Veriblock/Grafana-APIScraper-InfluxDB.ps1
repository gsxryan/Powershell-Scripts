#Veriblock Pool Monitor

#adapted from https://github.com/icanos/influxdb-posh

#Depends:
#InfluxDB, Grafana

#Add Total Shares in Recent Rounds, Avg Shares per recent round.
#default pool refresh 10 seconds, script 1m

#Environment Variables
$username = "fluxDBuser"
$password = "P@ssw0rd" | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username,$password)
$InfluxDB = "veriblock.contoso.com"
$BTCfeeskip = 12

do{

$LivePools = (Invoke-WebRequest https://gist.githubusercontent.com/gsxryan/c8de9faf79a7f29bb96d925702096023/raw/VeriBlockPoolList.txt).content
#$PoolList = Import-CSV C:\temp\PoolList.txt
$PoolList = ConvertFrom-Csv $LivePools

Function Add-InfluxMultiMetric {
    Param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,
        [Parameter(Mandatory = $true)]
        [string]$Database,
        [Parameter(Mandatory = $true)]
        [string]$SeriesName,
        [Parameter(Mandatory = $true)]
        [Hashtable]$Metrics,
        [Hashtable]$Tags
    )

    if (!$ComputerName.Contains(":")) {
        # Add default port if none specified
        $ComputerName = "$($ComputerName):8086"
    }

    if (!$Database) {
        Write-Error "Missing or invalid database name."
        return
    }

    if (!$SeriesName) {
        Write-Error "Missing or invalid series name"
        return
    }

    # Tags
    $TagsList = @()

    foreach ($Key in $Tags.Keys) {
        $TagsList += "$Key=$($Tags[$Key])"
    }

    $TagsCombined = [string]::Join(",", $TagsList)

    # Metrics
    $MetricsList = @()

    foreach ($Key in $Metrics.Keys) {
        $MetricsList += "$Key=$($Metrics[$Key])"
    }

    $MetricsCombined = [string]::Join(",", $MetricsList)

    if ($TagsList.Count -gt 0) {
        $BinaryData = "$SeriesName,$TagsCombined $MetricsCombined"
    }
    else {
        $BinaryData = "$SeriesName $MetricsCombined"
    }
    
    Invoke-WebRequest -Method Post -Uri "https://$ComputerName/write?db=$Database" -Credential $Cred -Body $BinaryData | Out-Null

    Write-Output "'$BinaryData' has been inserted."
}

foreach ($pool in $PoolList) {
$PoolAddress = $pool.address
$PoolName = $pool.name -replace ' ',''
$port = $pool.Port

$WebContent = (invoke-restmethod "http://$PoolAddress`:$port/api/summary/" -TimeoutSec 1)
#TestLine: $WebContent = (invoke-restmethod "http://vb-gpu.curecoin.net:8500/api/summary/" -TimeoutSec 1)


    if ($WebContent)
{
<# Variables Available
    poolAddress, currentRound, poolMiningBlock, miningOnTopOfBlock, blockchainHeight, nodeCoreStartTime, programVersion, poolType, isPoolOK, statusMessage #>

$BlockHeight = $WebContent.miningBlockNumber
    $RawVersion = $WebContent.applicationVersion #Prep Raw Version
$Version = $RawVersion -replace '[\S\s]*(\d\.\d\.[0-9]{1,3})[\S\s]*','$1'; $Version = $Version -replace '\.',''
$CurrentRd = $WebContent.currentRoundNumber
    $RawBlockHash = $WebContent.lastBlockHash #Prep Raw BlockHash
$BlockHash = $RawBlockHash.Substring($RawBlockHash.Length - 6)
$PoolFee = $WebContent.fee
$PoolHashRate = $WebContent.recentHashRate
$NetHashRate += $WebContent.recentHashRate

Add-InfluxMultiMetric -ComputerName "$InfluxDB" -Database "VeriBlock" -SeriesName "$PoolName" -Metrics @{ "Block" = "$BlockHeight"; "BlockHash" = "`"$BlockHash`""; "Round" = "$CurrentRd"; "Version" = "$Version"; "Fee" = "$PoolFee"; "PoolName" = "`"$PoolName`""; "HashRate" = "$PoolHashRate" }
$WebContent = $null
}
    else
{
echo "$PoolName is down, skipping"
#Add-InfluxMultiMetric -ComputerName "$InfluxDB" -Database "VeriBlock" -SeriesName "$PoolName" -Metrics @{ "Version" = "1"; }
}

}

#get Content for API Diff
$APIContent = invoke-restmethod "https://explore.veriblock.org/api/stats/network" -TimeoutSec 1

If ($APIContent)
{
$ExplorerHeight = $APIContent.lastBlock.height
$HashRate = $APIContent.hashRate
$Diff = $APIContent.difficulty
$feeByte = $APIContent.feeByte

Add-InfluxMultiMetric -ComputerName "$InfluxDB" -Database "VeriBlock" -SeriesName "APIExplorer" -Metrics @{ "Block" = "$ExplorerHeight"; "HashRate" = "$HashRate"; "Diff" = "$Diff"; "feeByte" = "$feeByte"; "PoolHashRate" = "$NetHashRate" }
$APIContent = $null
$NetHashRate = 0
}
else
{echo "API Explorer is down, skipping..."}

#get Content for BTC tx fee rates

If ($BTCfeeskip -gt 11){
$BTCFees = invoke-restmethod "https://bitcoinfees.earn.com/api/v1/fees/recommended" -TimeoutSec 1

If ($BTCFees)
{
$BTCFast = $BTCFees.fastestFee
$BTCHalf = $BTCFees.halfHourFee
$BTCHour = $BTCFees.hourFee

Add-InfluxMultiMetric -ComputerName "$InfluxDB" -Database "VeriBlock" -SeriesName "BTCstats" -Metrics @{ "Fastest" = "$BTCFast"; "HalfHr" = "$BTCHalf"; "Hour" = "$BTCHour" }
$BTCFees = $null
$BTCFeeskip = 0
}
else {echo "Bitcoinfees.earn.com down, skipping..."}
}
else {echo "BTC fees will run again in " 12 - $BTCfeeskip "cycles"}

    $BTCfeeskip += 1
    start-sleep -Seconds 50

}until($infinity)