# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 10 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         21/02/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file_20h2    = "en-gb_windows_10_business_editions_version_20h2_updated_feb_2021_x64_dvd_0d450cea.iso"
os_iso_file_2004    = "en-gb_windows_10_business_editions_version_2004_updated_feb_2021_x64_dvd_b8a04bec.iso"
os_iso_path         = "os/microsoft/desktop/10"

# OS Meta Data
os_family           = "Windows"
os_version          = "10"

# VM Hardware Settings
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "windows9_64Guest"
vm_boot_cmd         = ["<spacebar>"]
vm_shutdown_cmd     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Complete\""

# Provisioner Settings
script_files1       = [ "../../../script/windows/03-systemsettings.ps1",
                        "../../../script/windows/04-tlsconfig.ps1",
                        "../../../script/windows/40-ssltrust.ps1",
                        "../../../script/windows/87-bginfo.ps1",
                        "../../../script/windows/88-horizonagent.ps1" ]
script_files2       = [ "../../../script/windows/89-horizonosot.ps1" ]                        
inline_cmds1        = [ "powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
                        "Get-AppXPackage -AllUsers | Where {($_.name -notlike \"Photos\") -and ($_.Name -notlike \"Calculator\") -and ($_.Name -notlike \"Store\")} | Remove-AppXPackage -ErrorAction SilentlyContinue",
                        "Get-AppXProvisionedPackage -Online | Where {($_.DisplayName -notlike \"Photos\") -and ($_.DisplayName -notlike \"Calculator\") -and ($_.DisplayName -notlike \"Store\")} | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue",
                        "Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online" ]
inline_cmds2        = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]