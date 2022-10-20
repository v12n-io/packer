# Second-phase configuration of Windows 10 VDI installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# FileHandler Function
function File-Handler {
   param( [string]$source, [string]$destination )

   # Download file
   Try {
      Invoke-WebRequest -Uri $source -OutFile $destination | Out-Null
      Write-Host "File Downloaded: $destination"
   }
   Catch {
      Write-Host "File download failed for: $source"
      Exit -1
   }

   # Unblock file
   Try {
      Unblock-File $destination -Confirm:$false -ErrorAction Stop | Out-Null
      Write-Host "File Unblocked: $destination"
   }
   Catch {
      Write-Host "Unable to unblock file: $destination"
      Exit -1
   }
}

# SettingSet Explorer view options
Write-Host "-- Setting default Explorer view options ..."
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideDrivesWithNoMedia" 0 | Out-Null
Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSyncProviderNotifications" 0 | Out-Null

# Disable system hibernation
Write-Host "-- Disabling system hibernation ..."
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HiberFileSizePercent" -Value 0 | Out-Null
Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -Value 0 | Out-Null

# Disable password expiration for Administrator
Write-Host "-- Disabling password expiration for local Administrator user ..."
Set-LocalUser Administrator -PasswordNeverExpires $true

# Disable TLS 1.0
Write-Host "-- Disabling TLS 1.0 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.0" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" -Name "DisabledByDefault" -Value 1 | Out-Null
 
# Disable TLS 1.1
Write-Host "-- Disabling TLS 1.1 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.1" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" -Name "DisabledByDefault" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "Enabled" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" -Name "DisabledByDefault" -Value 1 | Out-Null

# Enabling TLS 1.2
Write-Host "-- Enabling TLS 1.2 ..."
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name "TLS 1.2" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Server" | Out-Null
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2" -Name "Client" | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "Enabled" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" -Name "DisabledByDefault" -Value 0 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "Enabled" -Value 1 | Out-Null
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" -Name "DisabledByDefault" -Value 0 | Out-Null

# Importing trusted CA certificates
Write-Host "-- Importing trusted CA certificates ..."
$webserver = $env:PKISERVER
$certRoot = "root.crt"
$certIssuing = "issuing.crt"
ForEach ($cert in $certRoot,$certIssuing) {
  Invoke-WebRequest -Uri ($webserver + "/" + $cert) -OutFile C:\$cert
}
Import-Certificate -FilePath C:\$certRoot -CertStoreLocation 'Cert:\LocalMachine\Root' | Out-Null
Import-Certificate -FilePath C:\$certIssuing -CertStoreLocation 'Cert:\LocalMachine\CA' | Out-Null
ForEach ($cert in $certRoot,$certIssuing) {
  Remove-Item C:\$cert -Confirm:$false
}

# Set Intranet server location and other filenames
$intranetServer = $env:INTRANETSERVER
$bginfoPath = $env:BGINFOPATH
$bginfoImg = $env:BGINFOIMG
$bginfoFile = $env:BGINFOFILE
$horizonPath = $env:HORIZONPATH
$horizonAgent = $env:HORIZONAGENT
$appvolsAgent = $env:APPVOLSAGENT
$appvolsServer = $env:APPVOLSSERVER
$fslogixAgent = $env:FSLOGIXAGENT
$osotAgent = $env:OSOTAGENT
$osotTemplate = $env:OSOTTEMPLATE

# Download standard wallpaper
Write-Host "-- Importing Wallpaper ..."
New-Item -Path "C:\Windows\Web" -Name "bginfo" -ItemType "directory" | Out-Null
$targetFolder = "C:\Windows\Web\bginfo"
$uri = ($intranetServer + "/" + $bginfoPath)
Invoke-WebRequest -Uri ($uri + "/" + $bginfoImg) -OutFile ($targetFolder + "\" + $bginfoImg)

# Install Bginfo
Write-Host "-- Installing BGinfo ..."
$targetFolder = "C:\Program Files\Bginfo"
New-Item $targetFolder -Itemtype Directory | Out-Null
Invoke-WebRequest -Uri ($uri + "/Bginfo64.exe") -OutFile $targetFolder\Bginfo64.exe
Invoke-WebRequest -Uri ($uri + "/" + $bginfoFile) -OutFile ($targetFolder + "\" + $bginfoFile)

# Install Horizon Agent
Write-Host "-- Installing Horizon Agent ..."
$uri = $intranetServer + "/" + $horizonPath + "/" + $horizonAgent
$target = Join-Path C:\ $horizonAgent
$listConfig = '/s /v "/qn REBOOT=ReallySuppress ADDLOCAL=Core,NGVC,RTAV,ClientDriveRedirection,V4V,VmwVaudio,PerfTracker"'
Try {
   File-Handler $uri $target
   Start-Process $target -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to install the Horizon Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item $target -Confirm:$false

# Install Horizon AppVols Agent
Write-Host "-- Installing AppVols Agent ..."
$uri = $intranetServer + "/" + $horizonPath + "/" + $appvolsAgent
$target = Join-Path C:\ $appvolsAgent
$listConfig = '/i ' + $target + ' "/qn REBOOT=ReallySuppress MANAGER_ADDR=' + $appvolsServer + ' MANAGER_PORT=443 EnforceSSLCertificateValidation=0"'
Try {
   File-Handler $uri $target
   Start-Process msiexec.exe -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to install the AppVolumes Agent"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item $target -Confirm:$false

# Install FSLogix
Write-Host "-- Installing FSLogix ..."
$uri = $intranetServer + "/" + $horizonPath + "/" + $fslogixAgent
$target = Join-Path C:\ $fslogixAgent
$listConfig = "/install /quiet /norestart"
Try {
   File-Handler $uri $target
   Start-Process $target -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to install FSLogix"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item $target -Confirm:$false

# Execute Horizon OS Optimization Tool
Write-Host "-- Executing OS Optimization Tool ..."
$uri = $intranetServer + "/" + $horizonPath + "/" + $osotAgent
$target = Join-Path C:\ $osotAgent
$listConfig = '-o -t "' + $osotTemplate + '" -visualeffect performance -notification disable -windowsupdate disable -officeupdate disable -storeapp remove-all -antivirus disable -securitycenter disable -f 0 1 2 3 4 5 6 7 8 9 10'
Try {
   File-Handler $uri $target
   Start-Process $target -ArgumentList $listConfig -Passthru -Wait -ErrorAction stop | Out-Null
}
Catch {
   Write-Error "Failed to run OSOT"
   Write-Error $_.Exception
   Exit -1 
}
Remove-Item $target -Confirm:$false

# Perform sdelete to reduce disk size
Write-Host "-- Executing SDELETE ..."
$uri = "https://download.sysinternals.com/files/SDelete.zip"
$target = "C:\SDelete.zip"
$exe = "C:\sdelete64.exe"
$listConfig = "-z c: /accepteula"
Try {
   File-Handler $uri $target
   Expand-Archive -LiteralPath $target -DestinationPath C:\ -Confirm:$false | Out-Null
   Start-Process $exe -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop | Out-Null
}
Catch {
   Write-Error "Failed to run SDelete"
   Write-Error $_.Exception
   Exit -1 
}
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
$source = [IO.Compression.ZipFile]::OpenRead($target)
$entries = $source.Entries
ForEach ($file in $entries) {
   Remove-Item -Path (Join-Path C:\ $file) -Confirm:$false
}
$source.Dispose()
Remove-Item $target -Confirm:$false

# Enabling RDP connections
Write-Host "-- Enabling RDP connections ..."
Start-Process netsh -ArgumentList 'advfirewall firewall set rule group="Remote Desktop" new enable=yes' -wait | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

Write-Host "-- Configuration complete ..."