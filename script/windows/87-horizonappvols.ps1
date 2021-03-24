# Install Horizon App Volumes Agent
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2103")
$installer = "App Volumes Agent.msi"
$appVolumesServer = "REPLACEWITHAPPVOLSERVER"
$listConfig = "/i ""C:\$installer"" /qn REBOOT=ReallySuppress MANAGER_ADDR=$appVolumesServer MANAGER_PORT=443 EnforceSSLCertificateValidation=1"

# Get AppVolumes Agent
Invoke-WebRequest -Uri ($uri + "/" + $installer) -OutFile C:\$installer

# Unblock installer
Unblock-File C:\$installer -Confirm:$false -ErrorAction Stop

# Install Horizon Agent
Try 
{
   #Start-Process C:\$installer -ArgumentList $listConfig -PassThru -Wait -ErrorAction Stop
   Write-Host "Skipping AppVolumes installation"
}
Catch
{
   Write-Error "Failed to install the AppVolumes Agent"
   Write-Error $_.Exception
   Exit -1 
}

# Cleanup on aisle 4...
Remove-Item C:\$installer -Confirm:$false