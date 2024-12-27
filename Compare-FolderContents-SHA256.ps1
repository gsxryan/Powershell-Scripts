#Compare the SHA256 hash of each file in two directories, Return only the differences.  Uncomment -Recurse to search subdirectories

$SourceDC = Get-ChildItem -Path \\server1\folder <#-Recurse#> | foreach  {Get-FileHash -Path $_.FullName}

$TestDC = Get-ChildItem -Path \\server2\folder <#-Recurse#> | foreach  {Get-FileHash -Path $_.FullName}

Compare-Object -ReferenceObject $SourceDC  -DifferenceObject $TestDC -Property hash -PassThru