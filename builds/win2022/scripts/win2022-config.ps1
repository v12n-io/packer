# Second-phase configuration of vanilla Windows Server installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

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

# Install OpenSSH
Write-Host " - Installing OpenSSH ..."
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null
Set-Service sshd -StartupType Automatic | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force | Out-Null

# Variables
$passwordLength = 20
$nonAlphaChars = 5
$ansibleUser = "REPLACEWITHANSIBLEUSERNAME"
Add-Type -AssemblyName 'System.Web'

# Creating Ansible user
Write-Host " - Creating user for Ansible access ..."
$ansiblePass = ([System.Web.Security.Membership]::GeneratePassword($passwordLength, $nonAlphaChars))
$secureString = ConvertTo-SecureString $ansiblePass -AsPlainText -Force
New-LocalUser -Name $ansibleUser -Password $secureString | Out-Null
$credential = New-Object System.Management.Automation.PsCredential($ansibleUser,$secureString)
$process = Start-Process cmd /c -Credential $credential -ErrorAction SilentlyContinue -LoadUserProfile
$newPass = ([System.Web.Security.Membership]::GeneratePassword($passwordLength, $nonAlphaChars))
$newSecureString = ConvertTo-SecureString $newPass -AsPlainText -Force
Set-LocalUser -Name $ansibleUser -Password $newSecureString | Out-Null
New-Item -Path "C:\Users\$ansibleUser" -Name ".ssh" -ItemType Directory | Out-Null
$content = @"
REPLACEWITHANSIBLEUSERKEY REPLACEWITHANSIBLEUSERNAME
"@ 
$content | Set-Content -Path "c:\users\$ansibleUser\.ssh\authorized_keys" | Out-Null

# Installing Cloudbase-Init
Write-Host " - Installing Cloudbase-Init ..."
$msiLocation = 'https://cloudbase.it/downloads'
$msiFileName = 'CloudbaseInitSetup_Stable_x64.msi'
Invoke-WebRequest -Uri ($msiLocation + '/' + $msiFileName) -OutFile C:\$msiFileName
Unblock-File -Path C:\$msiFileName
Start-Process msiexec.exe -ArgumentList "/i C:\$msiFileName /qn /norestart RUN_SERVICE_AS_LOCAL_SYSTEM=1" -Wait
Write-Host " - Configuring Cloudbase-Init for VMwareGuestInfoService ..."
$confFile = 'cloudbase-init.conf'
$confPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\"
$confContent = @"
[DEFAULT]
bsdtar_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\bsdtar.exe
mtools_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\bin\
verbose=true
debug=true
logdir=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\log\
logfile=cloudbase-init.log
default_log_levels=comtypes=INFO,suds=INFO,iso8601=WARN,requests=WARN
local_scripts_path=C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\
metadata_services=cloudbaseinit.metadata.services.vmwareguestinfoservice.VMwareGuestInfoService
plugins=cloudbaseinit.plugins.common.userdata.UserDataPlugin
"@
New-Item -Path $confPath -Name $confFile -ItemType File -Force -Value $confContent | Out-Null
Start-Process sc.exe -ArgumentList "config cloudbase-init start= delayed-auto" -wait | Out-Null
Remove-Item -Path ($confPath + "cloudbase-init-unattend.conf") -Confirm:$false 
Remove-Item -Path ($confPath + "Unattend.xml") -Confirm:$false 
Remove-Item C:\$msiFileName -Confirm:$false

# Enabling RDP connections
Write-Host " - Enabling RDP connections ..."
Start-Process netsh -ArgumentList 'advfirewall firewall set rule group="Remote Desktop" new enable=yes' -wait | Out-Null
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null

Write-Host " - Configuration complete ..."