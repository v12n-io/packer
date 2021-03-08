# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Ubuntu 18 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/02/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "ubuntu-18.04.4-server-amd64.iso"
os_iso_path         = "os/ubuntu/18"

# OS Meta Data
os_family           = "Linux"
os_version          = "Ubuntu18"

# VM Hardware Settings
vm_cpu_sockets      = 1
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 16384
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "ubuntu64Guest"

# Provisioner Settings
script_files        = [ ]
inline_cmds         = [ ]

# Packer Settings
http_directory      = "../../../config/linux/ubuntu18"
http_port_min       = 8000
http_port_max       = 8050