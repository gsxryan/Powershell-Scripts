# RCautomate.com
#Run as Administrator
#Popup a GUI window to request a list of PC Names.
#Ping those machines, if online verify and output the primary user of that machine.

#Request a list of machines to check
#$hostname = Read-Host "What is the machine name to check?" #Test Mode
# MECM: $hostname = $env:COMPUTERNAME
# Batch Script: Import GUI popup to paste list of hostnames

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
    $textBox.Text = "HOSTNAME" #Default input on popup
$form.Controls.Add($textBox)

 

$form.Topmost = $true

 

$form.Add_Shown({$textBox.Select()})
$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)

{

    $x = $textBox.Lines

    #split the data into an array by RETURN Key

    $x = $x.Split("`r")

    #IF that doesn't catch anything, split it by spaces.

         if ($x.Count -lt 2)

            { $x = $x.Split(" ")

    #eliminate any remaining spaces

    $x = $x.replace(' ','""')

}
 

foreach ($Hostname in $x)
{
    #Grab the AD-OU the machine is a member of
#(Get-ADComputer $Hostname).DistinguishedName
$Ping = (Test-Connection $Hostname -Count 1 -ErrorAction SilentlyContinue).ResponseTime
if($Ping)
{
    #Grab the most common user for the machine
$User = (Get-WmiObject -Class win32_process -ComputerName $Hostname -ErrorAction SilentlyContinue | Where-Object name -Match explorer -ErrorAction SilentlyContinue).getowner().user
echo "$Hostname, $User"
#Grab the Operating system of the computer
#(Get-WMIObject -ComputerName $Hostname win32_operatingsystem).name
$User = $null
$Ping = $null
}
else
{echo "$Hostname, Offline"
$Ping = $null}
}