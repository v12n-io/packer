# Enable RDP connections
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# Enabling RDP connections
Write-Host "Enabling RDP connections"
netsh advfirewall firewall set rule group="Remote Desktop" new enable=yes
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0 | Out-Null