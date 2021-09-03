# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 2016 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         04/08/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "en_windows_server_2016_updated_feb_2018_x64_dvd_11636692.iso"
os_iso_path         = "os/microsoft/server/2016"

# OS Meta Data
os_family           = "Windows"
os_version          = "2016"

# VM Hardware Settings
vm_firmware         = "efi-secure"
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "windows9Server64Guest"
vm_tools_update     = true
build_username      = "Administrator"
build_password      = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files        = [ "../../scripts/win2016-config.ps1" ]
inline_cmds         = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]