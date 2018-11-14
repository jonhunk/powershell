#Powershell window
param ( $Show )


#Sets Execution Policy to be RemoteSigned in order to download Signed installers from Microsoft's Website
    Set-ExecutionPolicy Unrestricted -Scope Process -Force 

    Write-Host "****Next IT Internal Active Agent 7 & Agent 8 Suite Prerequisites Check & Installation Kit for Server 2008 or 2012" -foregroundcolor Yellow -BackgroundColor DarkCyan
    Write-Host "****By: Jonathan Hunkapiller" -foregroundcolor Yellow -BackgroundColor DarkCyan
    Import-Module Servermanager

#Check Prereqs
    $CheckPREREQS = Get-WindowsFeature PowerShell-ISE, FS-FileServer, PowerShell, FS-FileServer, Storage-Services, WAS, WoW64-Support, Web-Default-Doc, Web-Dir-Browsing, Web-Http-Errors, Web-Static-Content, Web-Http-Logging, Web-Stat-Compression, Web-Filtering, Web-Windows-Auth, Web-Net-Ext, Web-Net-Ext45, Web-Asp-Net45, Web-ISAPI-Ext, Web-ISAPI-Filter, Web-Mgmt-Console, NET-Framework-Features, NET-Framework-45-Core, NET-Framework-45-ASPNET, NET-WCF-Services45, MSMQ-Server
    $CheckPREREQS | ft -GroupBy Install -wrap

#If MSMQueues was installed REBOOT
#Check MSMQ Install Status Beg
#    $CheckMSMQBeg = Get-WindowsFeature MSMQ-Server


#CHECK **AGENT 8** Active Directory Lightweight Directory Services
    $CheckADLDS=get-windowsfeature ADLDS
    if($CheckADLDS.Installed -eq "True") {Write-Host "[X] Active Directory LDS **For Agent 8** `t`t`t`tADLDS `t`t`t`t`t`t   Installed"}
    else {Write-Host "[ ] Active Directory LDS **For Agent 8** `t`t`t`tADLDS `t`t`t`t`t`t   Available"}

#CHECK **AGENT 8** Microsoft AppFabric 1.1 for Windows Server
    $AppFabricCachingService = Get-Service -Name 'AppFabricCachingService' -ErrorAction SilentlyContinue
    if($AppFabricCachingService) {Write-Host "[X] AppFabric **For Agent 8** `t`t`t`t`t`t`tAppFabricCachingService `t   Installed"}
    if(-not $AppFabricCachingService)  {Write-Host "[ ] AppFabric **For Agent 8** `t`t`t`t`t`t`tAppFabricCachingService `t   Downloadable"}

#CHECK IF WINDOWS VERSION IS 2008
function check-version {$Returned = $false
                $CheckOS=[Environment]::OSVersion.Version
                    if(($CheckOS.Major -eq 6) -and ($CheckOS.Minor -lt 2)) {
                #Checking to see if Windows Management Framework 3.0 is installed.
                    $PSResults=$PSVersionTable
                        if($PSResults.PSVersion.Major -gt 2) {
                         $Returned = $true
                           Write-Host "[X] Windows PowerShell 3.0 `t`t`t`t`t`t`t`tPowerShell"} 
                        else {Write-Host "[ ] Windows PowerShell 3.0 `t`t`t`t`t`t`t`tPowerShell"}}

        Return $Returned
    }        

#Prereqs Configuration 
    $sp32008check = check-version 
    if(($CheckPREREQS.Installed -Match "False") -or (-not $AppFabricCachingService) -or ($sp32008check))  { $userinput = Read-Host "`n***NOT all Preqs are installed. Do you wish to Install any missing Preqs? [y]yes or [n]no?"}
        else {Write-Host "****ALL Prereqs are Installed" -foregroundcolor Yellow -BackgroundColor DarkCyan}
            if($userinput -eq "n") {Write-Host "`n****Prereqs script is finished!`n" -foregroundcolor Yellow -BackgroundColor DarkCyan}
            if($userinput -eq "y") {Write-Host "`n****Starting missing Prereqs process...`n"  -foregroundcolor Yellow -BackgroundColor DarkCyan}
               
#Install Missing Prereqs
    if($userinput -eq "y") 
    {
            if(($CheckOS.Major -eq 6) -and ($CheckOS.Minor -lt 2)) {Write-Host "`n****Windows Version is 2008" -foregroundcolor Yellow -BackgroundColor DarkCyan}
                    #Checking to see if Windows Management Framework 3.0 is installed. If not, download and install it.
                    $Results=$PSVersionTable
                    if($Results.PSVersion.Major -lt 3) 
                        {
                        #download and install Windows Management Framework 3.0 
                        Write-Host "`n****Downloading and installing Windows Management Framework 3.0. 
                        `n****THIS WILL REQUIRE A SERVER REBOOT. 
                        `n****THEN RERUN THIS SCRIPT TO CONTINUE" -foregroundcolor Yellow -BackgroundColor DarkCyan
                        ((new-object net.webclient).DownloadFile("http://download.microsoft.com/download/E/7/6/E76850B8-DA6E-4FF5-8CCE-A24FC513FD16/Windows6.1-KB2506143-x64.msu","Windows6.1-KB2506143-x64.msu")) 
                        & .\Windows6.1-KB2506143-x64.msu
                        Exit
                        }            
        
        
        for ($i=0;$i -le $CheckPREREQS.Count;$i++) 
                {
                if($CheckPREREQS[$i].installed -match "False") {Add-WindowsFeature $CheckPREREQS[$i].name}
                }
        

        
        #CHECK **AGENT 8** Active Directory Lightweight Directory Services
        if($CheckADLDS.Installed -match "False") {$userinputADLDS = Read-Host  "`n **For Agent 8** Active Directory LDS is NOT installed. Do you wish to Install Active Directory LDS? [y]yes or [n]no?"}
            if($userinputADLDS -eq "y") {Add-WindowsFeature ADLDS}
       
        #CHECK **AGENT 8** Microsoft AppFabric 1.1 for Windows Server
        if(-not $AppFabricCachingService)  { $userinput = Read-Host "`n **For Agent 8** AppFabric is NOT installed. Do you wish to Install Microsoft AppFabric 1.1 for Windows Server? [y]yes or [n]no?"
            }
            if($userinput -eq "y") {Write-host "`n***Downloading and Installing Microsoft AppFabric 1.1 for Windows Server" -foregroundcolor Yellow -BackgroundColor DarkCyan
                ((new-object net.webclient).DownloadFile("http://download.microsoft.com/download/A/6/7/A678AB47-496B-4907-B3D4-0A2D280A13C0/WindowsServerAppFabricSetup_x64.exe","WindowsServerAppFabricSetup_x64.exe"))
                & .\WindowsServerAppFabricSetup_x64.exe
                }
            else{Write-Host "`n****Prereqs script is finished!`n" -foregroundcolor Yellow -BackgroundColor DarkCyan}
        
    }


#If MSMQueues was installed REBOOT
#Check MSMQ Install Status End
#    $CheckMSMQEnd = Get-WindowsFeature MSMQ-Server
#    if(($CheckMSMQBeg.installed -eq "False") -and ($CheckMSMQEnd.installed -eq "True")) {Restart-Computer -confirm}


#Sets Execution Policy to be Undefined in order to download Signed installers from Microsoft's Website
    Set-ExecutionPolicy Undefined -Scope Process -Force
  
   
#Powershell window not to close once script is finished
    Write-Host "Press any key to continue ..."
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 

    Function Pause ($Message = "Press any key to continue . . . ") {
    If ($psISE) {
        # The "ReadKey" functionality is not supported in Windows PowerShell ISE.
 
        $Shell = New-Object -ComObject "WScript.Shell"
        $Button = $Shell.Popup("Click OK to continue.", 0, "Script Paused", 0)
 
        Return
    }
 
    Write-Host -NoNewline $Message
 
    $Ignore =
        16,  # Shift (left or right)
        17,  # Ctrl (left or right)
        18,  # Alt (left or right)
        20,  # Caps lock
        91,  # Windows key (left)
        92,  # Windows key (right)
        93,  # Menu key
        144, # Num lock
        145, # Scroll lock
        166, # Back
        167, # Forward
        168, # Refresh
        169, # Stop
        170, # Search
        171, # Favorites
        172, # Start/Home
        173, # Mute
        174, # Volume Down
        175, # Volume Up
        176, # Next Track
        177, # Previous Track
        178, # Stop Media
        179, # Play
        180, # Mail
        181, # Select Media
        182, # Application 1
        183  # Application 2
 
    While ($KeyInfo.VirtualKeyCode -Eq $Null -Or $Ignore -Contains $KeyInfo.VirtualKeyCode) {
        $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    }
 
    Write-Host
} 