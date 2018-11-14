
#Run Powershell as Admin level


#Sets Execution Policy to be Unrestricted in order to download Signed installers from Microsoft's Website
    Set-ExecutionPolicy Unrestricted -Scope Process -Force 

#Set DNS Client UseSuffixWhenRegistering to True
    $netdnsclient = Get-DnsClient
   
    if($netdnsclient.InterfaceAlias -eq "Local Area Connection") { Set-DnsClient -InterfaceAlias "Local Area Connection" -UseSuffixWhenRegistering(1)}
        else {}
            if($netdnsclient.InterfaceAlias -eq "Ethernet") { Set-DnsClient -InterfaceAlias "Ethernet" -UseSuffixWhenRegistering(1)}
   

#Sets Execution Policy to be Restricted in order to download Signed installers from Microsoft's Website
    Set-ExecutionPolicy Restricted -Scope Process -Force