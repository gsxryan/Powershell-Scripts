<#
RCautomate.com
Fix Java Site Exceptions list
deployment.user.security.exception.sites=//fileserver01/Apps/JavaExceptions/exception.sites
This script will assume the logged on user had an issue with Java site launching.  
It utilizes User permissions, so an administrator is not required to apply the fix.
This will detect if the exception.sites file has been defined to the user profile path yet.
If not, it will copy it from the specified file share
The specified file share is assumed to be hosting a list of sites to be excepted for Java Checks.
#>

$ExceptionExists = Select-String "JavaExceptions/exception.sites" C:\Users\$env:USERNAME\AppData\LocalLow\Sun\Java\Deployment\deployment.properties

If ($null -eq $ExceptionExists)

{
Add-Content C:\Users\$env:USERNAME\AppData\LocalLow\Sun\Java\Deployment\deployment.properties "deployment.user.security.exception.sites=//fileserver01/Apps/JavaExceptions/exception.sites"
}