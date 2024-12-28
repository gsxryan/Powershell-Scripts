#StorJ Node Monitor

#Depends:
#InfluxDB, Grafana

#Environment Variables
$username = "fluxDBuser"
$password = "P@ssw0rd" | ConvertTo-SecureString -asPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($username,$password)
$InfluxDB = "server.contoso.com"
$node1 = "NodeHashString1"
$node2 = "NodeHashString2"
$nodelist = $node1, $node2

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

do{


Foreach ($node in $nodelist)
{
$Result = (Invoke-WebRequest https://api.storj.io/contacts/$node -TimeoutSec 5).content

if ($Result)
{
$NodeID = $Result -replace "[\S\s]*nodeID.{38}([0-9a-z]{5})[\S\s]*",'$1'
$reputation = $Result -replace "[\S\s]*reputation.{2}([0-9]{1,6})[\S\s]*",'$1'
$response = $Result -replace "[\S\s]*responseTime.{2}([0-9]{1,6})[\S\s]*",'$1'

Add-InfluxMultiMetric -ComputerName "$InfluxDB" -Database "StorJ" -SeriesName "$NodeID" -Metrics @{ "Reputation" = "$reputation"; "Response" = "$response"; }
$Result = $null
}
    else
{
echo "$node is down, skipping"
}

}
    start-sleep -Seconds 300

}until($infinity)

