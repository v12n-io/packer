# Second-phase configuration of vanilla Windows Server installation to progress Packer.io builds
# @author Michael Poore
# @website https://blog.v12n.io
# @source https://github.com/virtualhobbit
$ErrorActionPreference = "Stop"

# Variables
$passwordLength = 20
$nonAlphaChars = 5
$ansibleUser = "REPLACEWITHANSIBLEUSERNAME"
Add-Type -AssemblyName 'System.Web'

# Create the ansible user
$ansiblePass = ([System.Web.Security.Membership]::GeneratePassword($passwordLength, $nonAlphaChars))
Write-Host $ansiblePass
$secureString = ConvertTo-SecureString $ansiblePass -AsPlainText -Force
New-LocalUser -Name $ansibleUser -Password $secureString
$credential = New-Object System.Management.Automation.PsCredential($ansibleUser,$secureString)

# Create the home folder
$process = Start-Process cmd /c -Credential $credential -ErrorAction SilentlyContinue -LoadUserProfile

# Set random password on account
$newPass = ([System.Web.Security.Membership]::GeneratePassword($passwordLength, $nonAlphaChars))
$newSecureString = ConvertTo-SecureString $newPass -AsPlainText -Force
Set-LocalUser -Name $ansibleUser -Password $newSecureString

# Configure SSH public key
New-Item -Path "C:\Users\$ansibleUser" -Name ".ssh" -ItemType Directory
$content = @"
REPLACEWITHANSIBLEUSERKEY REPLACEWITHANSIBLEUSERNAME
"@ 

# Write public key to file
$content | Set-Content -Path "c:\users\$ansibleUser\.ssh\authorized_keys"