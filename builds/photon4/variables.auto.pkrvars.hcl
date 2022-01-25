# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Photon 4 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "photon-4.0-c001795b8.iso"
os_iso_path         = "os/photon/4"

# OS Meta Data
os_family           = "Linux"
os_version          = "Photon4"

# VM Hardware Settings
vm_firmware         = "efi"
vm_cpu_sockets      = 1
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 16384
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM Settings
vm_cdrom_remove     = true
vm_convert_template = false
vm_export_ovf       = true

# VM OS Settings
vm_os_type          = "vmwarePhoton64Guest"
build_username      = "REPLACEWITHUSERNAME"
build_password      = "REPLACEWITHUSERPASS"

# Provisioner Settings
script_files        = [ "scripts/photon4-config.sh" ]
inline_cmds         = []

# Packer Settings
http_directory      = "config"
http_file           = "photon4.json"