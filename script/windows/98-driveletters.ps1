# Change CD drive letters
# @author Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# Set first CD drive letter to Y:
Get-WmiObject win32_volume -filter 'DriveLetter = "D:"' | Set-WmiInstance -Arguments @{DriveLetter='Y:'}

# Set second CD drive letter to Z:
Get-WmiObject win32_volume -filter 'DriveLetter = "E:"' | Set-WmiInstance -Arguments @{DriveLetter='Z:'}