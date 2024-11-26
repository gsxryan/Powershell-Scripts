# RCautomate.com
# Forked from source: http://scriptolog.blogspot.com/2007/12/extracting-icons-with-powershell.html
# This example extracts the Citrix ICA Client exe image
# This could be useful when extracting images for creating your own custom shortcut files

###########################
##   Extract-Icon
##   Usage:
##      Extract-Icon -file C:\windows\system32\notepad.exe -saveTo c:\icons -ext ico

function Extract-Icon($file,$saveTo,$ext){
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    [System.Drawing.Icon]::ExtractAssociatedIcon($file).ToBitmap().Save("$saveTo\$BaseName.$ext")
} 

Extract-Icon -file "C:\Program Files (x86)\Citrix\ICA Client\CDViewer.exe" -saveTo "C:\temp"