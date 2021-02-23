# Secure delete of files
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$url = "https://download.sysinternals.com/files"
$zip = "SDelete.zip"
$exe = "sdelete64.exe"
$arg = "-z c: /accepteula"

# Get SDelete
Invoke-WebRequest -Uri ($url + "/" + $zip) -OutFile C:\$zip

# Unzip it
Expand-Archive -LiteralPath "C:\$zip" -DestinationPath C:\ -Confirm:$false

# Run SDelete
Try 
{
   Start-Process C:\$exe -ArgumentList $arg -PassThru -Wait -ErrorAction Stop
}
Catch
{
   Write-Error "Failed to run SDelete"
   Write-Error $_.Exception
   Exit -1 
}

# Delete files
[Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
$source = [IO.Compression.ZipFile]::OpenRead("C:\$zip")
$entries = $source.Entries
ForEach ($file in $entries)
{
    Remove-Item -Path C:\$file -Confirm:$false
}
$source.Dispose()
Remove-Item C:\$zip -Confirm:$false