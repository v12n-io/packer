# Second-phase configuration of Windows 10 VDI installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# SettingSet Explorer view options
Write-Host " - Setting default Explorer view options ..."
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0 | Out-Null

# Disable system hibernation
Write-Host " - Disabling system hibernation ..."
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 | Out-Null

# Disable password expiration for Administrator
Write-Host " - Disabling password expiration for local Administrator user ..."
Set-LocalUser Administrator -PasswordNeverExpires $true

# Disable TLS 1.0
Write-Host " - Disabling TLS 1.0 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value 1 | Out-Null
 
# Disable TLS 1.1
Write-Host " - Disabling TLS 1.1 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

# Enabling TLS 1.2
Write-Host " - Enabling TLS 1.2 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.2" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value 0 | Out-Null

# Importing trusted CA certificates
Write-Host " - Importing trusted CA certificates ..."
$webserver = "REPLACEWITHPKISERVER"
$url = "http://" + $webserver
$certRoot = "root.crt"
$certIssuing = "issuing.crt"
ForEach ($cert in $certRoot,$certIssuing) {
  Invoke-WebRequest -Uri ($url + "/" + $cert) -OutFile C:\$cert
}
Import-Certificate -FilePath C:\$certRoot -CertStoreLocation 'Cert:\LocalMachine\Root' | Out-Null
Import-Certificate -FilePath C:\$certIssuing -CertStoreLocation 'Cert:\LocalMachine\CA' | Out-Null
ForEach ($cert in $certRoot,$certIssuing) {
  Remove-Item C:\$cert -Confirm:$false
}

# Download standard wallpaper
Write-Host " - Importing Wallpaper ..."
New-Item -Path "C:\Windows\Web" -Name "v12n" -ItemType "directory" | Out-Null
$uri = ("REPLACEWITHINTRANET" + "/other/bginfo")
$sourcefile = "v12n-screen.jpg"
$targetFolder = "C:\Windows\Web\v12n"
Invoke-WebRequest -Uri ($uri + "/" + $sourcefile) -OutFile ($targetFolder + "\" + $sourcefile)

# Install / Configure Bginfo
Write-Host " - Installing BGinfo ..."
$uri = ("REPLACEWITHINTRANET" + "/other/bginfo")
$targetFolder = "C:\Program Files\Bginfo"
New-Item $targetFolder -Itemtype Directory | Out-Null
Invoke-WebRequest -Uri ($uri + "/Bginfo.exe") -OutFile $targetFolder\Bginfo.exe
Invoke-WebRequest -Uri ($uri + "/v12n.bgi") -OutFile $targetFolder\v12n.bgi
$targetFile          = "$targetFolder\BGinfo.exe"
$shortcutFile        = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Bginfo.lnk"
$scriptShell         = New-Object -ComObject WScript.Shell -Verbose
$shortcut            = $scriptShell.CreateShortcut($shortcutFile)
$shortcut.TargetPath = $targetFile
$arg1                = """$targetFolder\v12n.bgi"""
$arg2                = "/timer:0 /accepteula"
$shortcut.Arguments  = $arg1 + " " + $arg2
$shortcut.Save() | Out-Null

# Install Horizon Agent
Write-Host " - Installing Horizon Agent ..."
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2111")
$installer = "VMware-Horizon-Agent-x86_64-2111.1-8.4.0-19066669.exe"
$listConfig = "/s /v ""/qn REBOOT=ReallySuppress ADDLOCAL=Core,NGVC,RTAV,ClientDriveRedirection,V4V,VmwVaudio,PerfTracker"""
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop | Out-Null
Try {
   Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to install the Horizon Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

# Install Horizon AppVols Agent
Write-Host " - Installing AppVols Agent ..."
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2111")
$installer = "App Volumes Agent.msi"
$appVolumesServer = "REPLACEWITHAPPVOLSERVER"
$listConfig = "/i ""C:\$installer"" /qn REBOOT=ReallySuppress MANAGER_ADDR=$appVolumesServer MANAGER_PORT=443 EnforceSSLCertificateValidation=1"
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop | Out-Null
Try {
   Start-Process msiexec.exe -ArgumentList $listConfig -PassThru -Wait | Out-Null
}
Catch {
   Write-Error "Failed to install the AppVolumes Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

# Install FSLogix
Write-Host " - Installing FSLogix ..."
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2111")
$installer = "FSLogixAppsSetup.exe"
$listConfig = "/install /quiet /norestart"
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop | Out-Null
Try {
   Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to install FSLogix"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

# Execute Horizon OS Optimization Tool
#Write-Host " - Executing OS Optimization Tool ..."
#$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2111")
#$files = @("VMwareHorizonOSOptimizationTool-x86_64-1.0_2111.exe","VMwareOSOptimizationTool.exe.config","win10_1809_1909.xml")
#$exe = $files[0]
#$arg = "-o -t " + $files[2]
#ForEach ($file in $files) {
    #Invoke-WebRequest -Uri ($uri + "/" + $file) -OutFile $env:TEMP\$file
#}
#Set-Location $env:TEMP | Out-Null
#Try {
  #Start-Process $exe -ArgumentList $arg -Passthru -Wait -ErrorAction stop | Out-Null
#}
#Catch {
  #Write-Error "Failed to run OSOT"
  #Write-Error $_.Exception
  #Exit -1 
#}
#ForEach ($file in $files) {
  #Remove-Item -Path $env:TEMP\$file -Confirm:$false
#}

# Perform sdelete to reduce disk size
Write-Host " - Executing SDELETE ..."
$url = "https://download.sysinternals.com/files"
$zip = "SDelete.zip"
$exe = "sdelete64.exe"
$arg = "-z c: /accepteula"
Invoke-WebRequest -Uri ($url + "/" + $zip) -OutFile C:\$zip
Expand-Archive -LiteralPath "C:\$zip" -DestinationPath C:\ -Confirm:$false | Out-Null
Try {
   Start-Process C:\$exe -ArgumentList $arg -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to run SDelete"
   Write-Error $_.Exception
   Exit -1 
}
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
$source = [IO.Compression.ZipFile]::OpenRead("C:\$zip")
$entries = $source.Entries
ForEach ($file in $entries) {
   Remove-Item -Path C:\$file -Confirm:$false
}
$source.Dispose()
Remove-Item C:\$zip -Confirm:$false

# Enabling RDP connections
Write-Host " - Enabling RDP connections ..."
Start-Process netsh -ArgumentList 'advfirewall firewall set rule group="Remote Desktop" new enable=yes' -wait | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

Write-Host " - Configuration complete ..."