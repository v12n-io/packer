# Copy default wallpaper
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

# Variables
$uri = ("REPLACEWITHINTRANET" + "/other/bginfo")
$targetFolder = "C:\Windows\Web\Wallpaper\Windows"

# Get files
Invoke-WebRequest -Uri ($uri + "/v12n-desktop-background.jpg") -OutFile $targetFolder\v12n-desktop-background.jpg