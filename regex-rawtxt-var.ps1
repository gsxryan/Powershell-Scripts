#When a Rawfile contains data you would like to assign to a variable.

<#
EX data;
Cluster Info Data Here
id 000051678A6KBISA
total_cap 111.8TB
randomtext 12623A
#>

$id = Select-String '(?<=id )[^\n\r]*' C:\Temp\Testfile.txt | ForEach-Object { $_.Matches[0].Value }
$totalcap = Select-String '(?<=total_cap )[\d{1,}.\d{1,}]*' C:\Temp\Testfile.txt | ForEach-Object { $_.Matches[0].Value }