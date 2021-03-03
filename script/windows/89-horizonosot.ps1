# Execute VMware OS Optimization Tool
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io
$ErrorActionPreference = "Stop"

$uri = ("REPLACEWITHINTRANET" + "/vmware/horizon/2012/8.1.0")
$files = @("VMwareOSOptimizationTool.exe","VMwareOSOptimizationTool.exe.config","win10_1809_1909.xml")
$exe = $files[0]
$arg = "-o -t " + $files[2]

# Get the OSOT files
ForEach ($file in $files) {
    Invoke-WebRequest -Uri ($uri + "/" + $file) -OutFile $env:TEMP\$file
}

# Change to temp folder
Set-Location $env:TEMP

# Run OSOT
Try 
{
  Start-Process $exe -ArgumentList $arg -Passthru -Wait -ErrorAction stop
}
Catch
{
  Write-Error "Failed to run OSOT"
  Write-Error $_.Exception
  Exit -1 
}

# Delete files
ForEach ($file in $files)
{
  Remove-Item -Path $env:TEMP\$file -Confirm:$false
}