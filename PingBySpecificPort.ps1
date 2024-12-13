#paste a list of items to ping to resolve IP address

#Batch Paste Input for powershell
#https://docs.microsoft.com/en-us/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1

<# 
BUG: commas [,] separation in the list will break the script, clean this data out.

Example: Include key locations in the network to determine if WAN or other infrastructure components are Down.
PhysicalHost01
VirtualHost01
Workstation35
WanGatewayRouter01
AppServer01
DomainControllerMain01
DomainControllerFLD02
FileServer01
CitrixServer01
DevServer01
TestServer01
#>

Start-Transcript C:\temp\PingTXTlist.log

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Computername List'
$form.Size = New-Object System.Drawing.Size(300,300)
$form.StartPosition = 'CenterScreen'

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(100,220)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton
$form.Controls.Add($okButton)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Location = New-Object System.Drawing.Point(200,220)
$cancelButton.Size = New-Object System.Drawing.Size(75,23)
$cancelButton.Text = 'Cancel'
$cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $cancelButton
$form.Controls.Add($cancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please enter the computerlist below:'
$form.Controls.Add($label)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(10,40)
$textBox.Size = New-Object System.Drawing.Size(260,150)
# Set the Multiline property to true.
    $textBox.Multiline = $true
#Add vertical scroll bars to the TextBox control.
    $textBox.ScrollBars = "Vertical"
#Allow the ENTER key to be entered in the TextBox control.
    $textBox.AcceptsReturn = $true
#Allow the TAB key to be entered in the TextBox control.
    $textBox.AcceptsTab = $true
#Set WordWrap to true to allow text to wrap to the next line.
    $textBox.WordWrap = $true
#Set the default text of the control.
    $textBox.Text = "Workstation25"
$form.Controls.Add($textBox)

$form.Topmost = $true

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $x = $textBox.Text
    #split the data into an array by RETURN Key
    $x = $x.Split("`r")
    #IF that doesn't catch anything, split it by spaces.
         if ($x.Count -lt 2)
            { $x = $x.Split(" ")
}
}

$port = Read-Host "Ping ICMP?  Press Enter.  Otherwise enter the port# you'd like to ping"


foreach ($item in $x) {
    #cut out the invalid characters in the array
    $machine = $item.Split([IO.Path]::GetInvalidFileNameChars()) -join ''
    #cut out the leading / trailing spaces
    $machine = $item.trim()
    #BUG - The last return item may error due to being blank, but not null.
    if ($null -ne $machine){
     $ping = (Test-Connection $machine -Count 1 -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue).IPV4Address.IPAddressToString}
if(($null -ne $ping))
{Write-Host "$machine, $ping"
$portresult = (Test-NetConnection $machine -Port $port).TcpTestSucceeded
Write-Host "$port, $portresult"
$Ping = $null
$machine = $null}
else
{
Write-Output "$machine, Offline"
$ping = $null
$machine = $null}
}

Stop-Transcript 