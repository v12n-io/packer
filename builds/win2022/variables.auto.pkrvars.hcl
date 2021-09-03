# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 2022 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         02/09/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "en-us_windows_server_2022_x64_dvd_620d7eac.iso"
os_iso_path         = "os/microsoft/server/2022"

# OS Meta Data
os_family           = "Windows"
os_version          = "2022"

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

# Build Settings
vm_cdrom_remove     = false
vm_convert_template = false

# VM OS Settings
vm_os_type          = "windows2019srv_64Guest"
vm_tools_update     = true
build_username      = "Administrator"
build_password      = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files        = [ "../../win2022-config.ps1" ]
inline_cmds         = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]