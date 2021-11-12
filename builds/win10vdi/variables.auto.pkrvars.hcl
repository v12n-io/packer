# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 10 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         09/11/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "en-gb_windows_10_business_editions_version_21h1_updated_aug_2021_x64_dvd_694d89d9.iso"
os_iso_path         = "os/microsoft/desktop/10"

# OS Meta Data
os_family           = "Windows"
os_version          = "10"

# VM Hardware Settings
vm_firmware         = "bios"
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 4096
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "windows9_64Guest"
build_username      = "Administrator"
build_password      = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files        = [ "../../scripts/win10vdi-config.ps1" ]
inline_cmds         = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]