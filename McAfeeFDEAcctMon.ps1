#RCautomate.com
#After installing McAfee FDE and a User login, script will monitor for the users Encryption account to be allocated.
#This is useful when provisioning a users PC and assisting with account setup before they leave the imaging center.
#$env:USERNAME assumes the logged on user is being provisioned, this can be changed to another user if remotely provisioned.

echo "Waiting for McAfee Encryption account to load"
echo "When User successfully added appears, you can reboot to setup McAfee FDE Account"
echo "CTRL+C to exit"

echo "checking for new policies..."
Start-Process -Filepath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList "-c"
Start-Sleep -s 5

echo "enforcing policies locally..."
Start-Process -Filepath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList "-e"
Start-Sleep -s 5

echo "collecting and sending properties..."
Start-Process -Filepath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList "-p"
Start-Sleep -s 5

echo "sending events..."
Start-Process -Filepath "C:\Program Files\McAfee\Agent\cmdagent.exe" -ArgumentList "-f"

echo "Watching for User Account to be added..."
gc "C:\Program Files\McAfee\Endpoint Encryption Agent\MfeEpe.log" -wait | sls "userLib: user $env:username.*successfully added"