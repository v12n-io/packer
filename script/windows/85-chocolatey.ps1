# Install Chocolatey
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# Run Chocolatey Install
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Allow Global Confirmation and Install Chrome
& choco feature enable -n allowGlobalConfirmation
& choco install googlechrome
& choco install powershell-core