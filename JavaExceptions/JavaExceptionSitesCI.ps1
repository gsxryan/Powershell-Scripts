<# RCAutomate.com - Developed for SCCM / MECM CI rule
Verify that the local Java Exception sites include the site http://unsignedjavacodesite.com
#>

<#CI Check#>
param($DestFile="c:\windows\sun\java\deployment\exception.sites",$site="http://unsignedjavacodesite.com")
$PrevExceptions = Get-Content $DestFile
if($PrevExceptions -contains $site){RETURN 0}
else {RETURN 1}

<#CI Remediate#>
param ($DestFile="c:\windows\sun\java\deployment\exception.sites",$site="http://unsignedjavacodesite.com")
if (!(Test-Path $DestFile)) 
    {$null|out-file -filepath $DestFile}
if ($PrevExceptions -notcontains $site)
    {"$site"|out-file -filepath $DestFile -append}