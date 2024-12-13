<# Smart Card Troubleshooting in powershell
Can be useful when no SmartCard is detected on a machine.

https://learn.microsoft.com/en-us/windows/security/identity-protection/smart-cards/smart-card-group-policy-and-registry-settings
#Manual Run:

Get-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\Calais" -Name "TransactionTimeoutDelay"
Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Cryptography\Defaults\Provider\Microsoft Base Smart Card Crypto Provider" -Name "TransactionTimeoutMilliseconds"
Get-ItemProperty -Path "HKLM:SOFTWARE\HID Global\SnapIns\EventService\EventsMonitoring\SCard" -Name "ReaderListPollingPeriod"
Get-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\HID Global\SnapIns\EventService\EventsMonitoring\SCard" -Name "ReaderListPollingPeriod"
#>

#Autorun
Get-ItemProperty -Path "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography\Calais" -Name "TransactionTimeoutDelay"

<# 
"TransactionTimeoutDelay"=dword:0000002d 
DWORD Decimal value range of 5-60 2d=45 seconds.
The smart card service is a single threaded app. Meaning it processes events serially, one at a time. If any errors occur or the card doesn’t return a response, then SmartCard is hung and won’t process any more events until it is reset.
Microsoft suggests using the MAX value of 60 seconds.#>

Get-ItemProperty -Path "HKLM:SOFTWARE\Microsoft\Cryptography\Defaults\Provider\Microsoft Base Smart Card Crypto Provider" -Name "TransactionTimeoutMilliseconds"

<# 
"TransactionTimeoutMilliseconds"=dword:00000bb8 
Decimal value range of 1500 to 5000 0bb8=3 seconds
The default timeout values allow you to specify whether transactions that take an excessive amount of time will fail.
Default value: 000005dc1500
The default timeout for holding transactions to the smart card is 1.5 seconds. The max value is 5 seconds.

 #>
# "ReaderListPollingPeriod"=dword:00007530 - X64 Application
Get-ItemProperty -Path "HKLM:SOFTWARE\HID Global\SnapIns\EventService\EventsMonitoring\SCard" -Name "ReaderListPollingPeriod"

#This value tells how often to check for a change in the card reader.  X86 Application
Get-ItemProperty -Path "HKLM:SOFTWARE\Wow6432Node\HID Global\SnapIns\EventService\EventsMonitoring\SCard" -Name "ReaderListPollingPeriod"

