#this task will run every 1 min
#detect if (IF) HeavyGame is running, if it is, close zminer
#if (else) HeavyGame is not running look for zminer, if it's not running open it.

$HeavyGame = (Get-Process -ProcessName SoTGame).cpu
$ZenMiner = (Get-Process -ProcessName miner).cpu

if (!$HeavyGame) {

echo "HeavyGame is not running, checking to make sure zminer is running"

       if (!$ZenMiner) {
            echo "Zminer is not running, starting zminer"
            Start-Process "C:\Tools\Zec Miner 0.3.4b\0.3.4b\miner.exe" -ArgumentList "--server us1.zhash.pro --user hash.hostname --pass x --port 3058"
                        }
        else
                        {
            echo "Zminer is running, we're MINING! Doing nothing"
                        }
}

else
{
echo "HeavyGame is running, make sure zminer has stopped"
Stop-Process -ProcessName miner
}