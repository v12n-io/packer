# Create a standard user on the host
# @author Michael Poore
# @website https://blog.v12n.io
# @source https://github.com/virtualhobbit
$ErrorActionPreference = "Stop"

# Variables
$user = "REPLACEWITHWINDOWSUSER"
$pass = "REPLACEWITHWINDOWSPASS"
Add-Type -AssemblyName 'System.Web'

# Create the user
$secureString = ConvertTo-SecureString $pass -AsPlainText -Force
New-LocalUser -Name $user -Password $secureString