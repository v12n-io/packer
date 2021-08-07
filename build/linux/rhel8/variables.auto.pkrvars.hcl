# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for RHEL 8 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         04/08/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "rhel-8.3-x86_64-dvd.iso"
os_iso_path         = "os/rhel/8"

# OS Meta Data
os_family           = "Linux"
os_version          = "RHEL8"

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
vm_os_type          = "rhel8_64Guest"
rhsm_user           = "REPLACEWITHRHSMUSER"
rhsm_pass           = "REPLACEWITHRHSMPASS"

# Provisioner Settings
script_files        = [ "../../../script/linux/rhel/rhel8-config.sh" ]
inline_cmds         = []

# Packer Settings
http_directory      = "../../../config/linux/rhel8"
http_port_min       = 8000
http_port_max       = 8050