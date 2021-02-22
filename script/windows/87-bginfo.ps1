# Install BGInfo
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# Variables
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