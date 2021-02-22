# Install Horizon Agent
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2012/8.1.0")
$installer = "VMware-Horizon-Agent-x86_64-2012-8.1.0-17352461.exe"
$listConfig = "/s /v ""/qn REBOOT=ReallySuppress ADDLOCAL=Core,NGVC,RTAV,ClientDriveRedirection,V4V,VmwVaudio,PerfTracker"""

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
   Write-Error "Failed to install the Horizon Agent"
   Write-Error $_.Exception
   Exit -1 
}

# Cleanup on aisle 4...
Remove-Item C:\$installer -Confirm:$false