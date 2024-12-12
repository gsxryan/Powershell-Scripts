# RCautomate.com

# Use caution with this one, as I don't recall if it was used in production.  Assume this is in Test/Dev.

#Test Line:
#$GetFiles = Get-ChildItem C:\Apps\LongFolderWeb -Recurse -File | select Fullname, LastWriteTime, LastAccessTime | Where LastAccessTime -lt  (Get-Date).AddDays(-60) 

 #Identify subfolders to parse ( so this will not delete empty root folders)
 $SearchDirs = (Get-ChildItem \\fileserver01\directories -Directory).Name

 foreach ($folder in $SearchDirs)
 {
  #get all the empty folders, it will probably fail on parent folders, so keep running until there are none left - the children will be deleted on each cycle.
     #doesn't include hidden folders or files as valid
     $i=1
  do {
     $EmptyFolders = Get-ChildItem \\fileserver01\directories\$folder -directory -recurse | Where-Object { (Get-ChildItem $_.fullName).count -eq 0 } | Select-Object -expandproperty FullName
     $EmptyFolders | Out-File C:\temp\EmptyFolderslist.log -Append
         
     #remove the folders
    Write-Host "About to delete the following, Press enter to continue..."
    Write-Host $EmptyFolders
    pause
     $EmptyFolders | Foreach-Object { Remove-Item $_ } #maybe add -Force if there are issues
     #Dump the empty folders list for each cycle
     $status = "$folder Delete Cycle $i"
     $status | Out-File C:\temp\EmptyFolderslist.log -Append
     Write-Host $status
          $i++
 } while ($EmptyFolders.count -gt 0)
 }
 