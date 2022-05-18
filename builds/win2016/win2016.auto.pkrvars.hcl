# ----------------------------------------------------------------------------
# Name:         win2016.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 2016 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "win2016.iso"
os_iso_path                     = "ISO"

# OS Meta Data
vm_os_family                    = "Windows"
vm_os_type                      = "Server"
vm_os_vendor                    = "Windows"
vm_os_version                   = "2016"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 4
vm_mem_size                     = 4096
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 40000
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = true
vcenter_content_library_ovf     = false
vcenter_content_library_destroy = false

# VM OS Settings
vm_guestos_type                 = "windows9Server64Guest"
build_username                  = "Administrator"
build_password                  = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files                    = [ "scripts/win2016-config.ps1" ]
inline_cmds                     = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]