# RCautomate.com
#Disable UDP in RDP to prevent locking sessions
#TCP may be slower, but should provide a more reliable experience.

new-itemproperty -path "HKLM:SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client" -name "fClientDisableUDP" -propertytype DWORD -value "1" -force
