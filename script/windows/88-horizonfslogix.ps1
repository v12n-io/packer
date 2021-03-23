# Install FSLogix
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2012/8.1.0")
$installer = "FSLogixAppsSetup.exe"
$listConfig = "/install /quiet /norestart"

# Get Horizon Agent
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer

# Unblock installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop

# Install Horizon Agent
Try 
{
   Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop
}
Catch
{
   Write-Error "Failed to install FSLogix"
   Write-Error $_.Exception
   Exit -1 
}

# Cleanup on aisle 4...
Remove-Item C:\$installer -Confirm:$false