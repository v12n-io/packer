# Second-phase configuration of Windows 10 VDI installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

#######################################
# SettingSet Explorer view options
#######################################
Write-Host "Setting default Explorer view options"
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0 | Out-Null

#######################################
# Disable system hibernation
#######################################
Write-Host "Disabling system hibernation"
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 | Out-Null

#######################################
# Disable password expiration for Administrator
#######################################
Write-Host "Disabling password expiration for local Administrator user"
Set-LocalUser Administrator -PasswordNeverExpires $true

#######################################
# Disable TLS 1.0
#######################################
Write-Host "Disabling TLS 1.0"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

####################################### 
# Disable TLS 1.1
#######################################
Write-Host "Disabling TLS 1.1"
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

#######################################
# Importing trusted CA certificates
#######################################
Write-Host "Importing trusted CA certificates"
$webserver = "REPLACEWITHPKISERVER"
$url = "http://" + $webserver
$certRoot = "rootca.cer"
$certIssuing = "issuingca.cer"
ForEach ($cert in $certRoot,$certIssuing) {
  Invoke-WebRequest -Uri ($url + "/" + $cert) -OutFile C:\$cert
}
Import-Certificate -FilePath C:\$certRoot -CertStoreLocation 'Cert:\LocalMachine\Root'
Import-Certificate -FilePath C:\$certIssuing -CertStoreLocation 'Cert:\LocalMachine\CA'
ForEach ($cert in $certRoot,$certIssuing) {
  Remove-Item C:\$cert -Confirm:$false
}

#######################################
# Download standard wallpaper
#######################################
$uri = ("REPLACEWITHINTRANET" + "/other/bginfo")
$sourcefile = "v12n-desktop-background.jpg"
$targetFolder = "C:\Windows\Web\Wallpaper\Windows"
# Get file
Invoke-WebRequest -Uri ($uri + "/" + $sourcefile) -OutFile ($targetFolder + "\" + $sourcefile)

#######################################
# Install / Configure Bginfo
#######################################
$uri = ("REPLACEWITHINTRANET" + "/other/bginfo")
# Create folder
$targetFolder = "C:\Program Files\Bginfo"
New-Item $targetFolder -Itemtype Directory
# Get files
Invoke-WebRequest -Uri ($uri + "/Bginfo.exe") -OutFile $targetFolder\Bginfo.exe
Invoke-WebRequest -Uri ($uri + "/v12n.bgi") -OutFile $targetFolder\v12n.bgi
# Create shortcut
$targetFile          = "$targetFolder\BGinfo.exe"
$shortcutFile        = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\Bginfo.lnk"
$scriptShell         = New-Object -ComObject WScript.Shell -Verbose
$shortcut            = $scriptShell.CreateShortcut($shortcutFile)
$shortcut.TargetPath = $targetFile
$arg1                = """$targetFolder\v12n.bgi"""
$arg2                = "/timer:0 /accepteula"
$shortcut.Arguments  = $arg1 + " " + $arg2
$shortcut.Save()

#######################################
# Install Horizon Agent
#######################################
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2103")
$installer = "VMware-Horizon-Agent-x86_64-2103-8.2.0-17771933.exe"
$listConfig = "/s /v ""/qn REBOOT=ReallySuppress ADDLOCAL=Core,NGVC,RTAV,ClientDriveRedirection,V4V,VmwVaudio,PerfTracker"""
# Get Horizon Agent
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop
# Install Horizon Agent
Try {
   Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop
}
Catch {
   Write-Error "Failed to install the Horizon Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

#######################################
# Install Horizon AppVols Agent
#######################################
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2103")
$installer = "App Volumes Agent.msi"
$appVolumesServer = "REPLACEWITHAPPVOLSERVER"
$listConfig = "/i ""C:\$installer"" /qn REBOOT=ReallySuppress MANAGER_ADDR=$appVolumesServer MANAGER_PORT=443 EnforceSSLCertificateValidation=1"
# Get AppVolumes Agent
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop
# Install Horizon AppVopls Agent
Try {
   Start-Process msiexec.exe -ArgumentList $listConfig -PassThru -Wait
}
Catch {
   Write-Error "Failed to install the AppVolumes Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

#######################################
# Install FSLogix
#######################################
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2103")
$installer = "FSLogixAppsSetup.exe"
$listConfig = "/install /quiet /norestart"
# Get FSLogix
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop
# Install FSLogix
Try {
   Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop
}
Catch {
   Write-Error "Failed to install FSLogix"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item C:\$installer -Confirm:$false

#######################################
# Execute Horizon OS Optimization Tool
#######################################
$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2012/8.1.0")
$files = @("VMwareOSOptimizationTool.exe","VMwareOSOptimizationTool.exe.config","win10_1809_1909.xml")
$exe = $files[0]
$arg = "-o -t " + $files[2]
# Get the OSOT files
ForEach ($file in $files) {
    Invoke-WebRequest -Uri ($uri + "/" + $file) -OutFile $env:TEMP\$file
}
# Change to temp folder
Set-Location $env:TEMP
# Run OSOT
Try {
  Start-Process $exe -ArgumentList $arg -Passthru -Wait -ErrorAction stop
}
Catch {
  Write-Error "Failed to run OSOT"
  Write-Error $_.Exception
  Exit -1 
}
# Delete files
ForEach ($file in $files) {
  Remove-Item -Path $env:TEMP\$file -Confirm:$false
}

#######################################
# Perform sdelete to reduce disk size
#######################################
$url = "https://download.sysinternals.com/files"
$zip = "SDelete.zip"
$exe = "sdelete64.exe"
$arg = "-z c: /accepteula"
Invoke-WebRequest -Uri ($url + "/" + $zip) -OutFile C:\$zip
Expand-Archive -LiteralPath "C:\$zip" -DestinationPath C:\ -Confirm:$false
# Run SDelete
Try {
   Start-Process C:\$exe -ArgumentList $arg -PassThru -Wait -ErrorAction Stop
}
Catch {
   Write-Error "Failed to run SDelete"
   Write-Error $_.Exception
   Exit -1 
}
# Delete files
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$source = [IO.Compression.ZipFile]::OpenRead("C:\$zip")
$entries = $source.Entries
ForEach ($file in $entries) {
    Remove-Item -Path C:\$file -Confirm:$false
}
$source.Dispose()
Remove-Item C:\$zip -Confirm:$false

#######################################
# Enabling RDP connections
#######################################
Write-Host "Enabling RDP connections"
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

#######################################
# Set CD drive letters
#######################################
Write-Host "Changing CD drive letters"
Get-WmiObject win32_volume -filter 'DriveLetter = "D:"' | Set-WmiInstance -Arguments @{DriveLetter='Y:'}
Get-WmiObject win32_volume -filter 'DriveLetter = "E:"' | Set-WmiInstance -Arguments @{DriveLetter='Z:'}