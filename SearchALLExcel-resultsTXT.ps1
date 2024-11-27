<# Export XLS and XLSX files to CSV, 
do a search on the CSV Flat files to find, export data to text file
 and report the information in notepad

RCautomate.com
Reference Sources:
https://www.mssqltips.com/sqlservertip/3223/extract-and-convert-all-excel-worksheets-into-csv-files-using-powershell/

Assumes C:\temp exists
Caution: Will remove all *.csv files in C:\temp
#>

#Grab the Search Location
$SourceLoc = "O:\Customer Data\" #Default location
echo "Searching in $SourceLoc, enter CD to change directory"

$Keyword = Read-Host -Prompt 'Input Your Keyword to search all XLS(x) files'

#If the user needs to change the default directory, enter CD
if ($Keyword -eq "CD")
{
    $SourceLoc = Read-Host -Prompt 'Input the directory'
    $Keyword = Read-Host -Prompt 'Input Your Keyword'
} 


#export to CSV File function
Function ExportWSToCSV ($excelFileName, $csvLoc)
{
    $excelFile = $SourceLoc + "\" + $excelFileName
    $E = New-Object -ComObject Excel.Application
    $E.Visible = $false
    $E.DisplayAlerts = $false
    $wb = $E.Workbooks.Open($excelFile)
    foreach ($ws in $wb.Worksheets)
    {
        $n = $excelFileName + "_" + $ws.Name
        $ws.SaveAs($csvLoc + $n + ".csv", 6)
    }
    $E.Quit()
}

#Parse through all xls, ans xlsx files within the folder and export to CSV
$BaseNames = (Get-ChildItem $SourceLoc\* -include *.xlsx, *.xls).name
foreach($basefilename in $BaseNames)
{
    
    ExportWSToCSV -excelFileName $basefilename -csvLoc "C:\Temp\"
    
    
}

#Search the exported CSV Files
$CSVNames = (Get-ChildItem C:\Temp -filter *.csv).name

foreach($csvfile in $CSVNames)
{
$csvfilebase = $csvfile
echo "Results from file $csvfile..." | Out-File -FilePath C:\Temp\Results.txt -Append
import-csv "C:\Temp\$csvfile" | ?{$_ -match "$Keyword"} | <# ft -AutoSize |#>Out-String -Width 8192 | Out-File -FilePath C:\Temp\Results.txt -Append
}

#Open results in a text file
start-process notepad.exe C:\temp\Results.txt
sleep -Seconds 5

#Cleaup
del C:\Temp\Results.txt
#delete the generated CSV files when complete
del C:\Temp\*.csv