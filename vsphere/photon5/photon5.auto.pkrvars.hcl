# ----------------------------------------------------------------------------
# Name:         photon5.auto.pkrvars.hcl
# Description:  Required vSphere variables for Photon 4 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------
#
# ISO Settings
os_iso_file                     = "photon-5.0-9e778f409.iso"
os_iso_path                     = "os/photon/5"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "Photon"
vm_os_version                   = "5.0 Beta"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 1
vm_cpu_cores                    = 1
vm_mem_size                     = 2048
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 32768
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
vm_guestos_type                 = "vmwarePhoton64Guest"

# Provisioner Settings
script_files                    = [ "scripts/config.sh" ]
inline_cmds                     = []