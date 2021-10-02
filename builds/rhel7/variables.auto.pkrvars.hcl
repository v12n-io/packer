# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for RHEL 7 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         30/09/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "rhel-server-7.9-x86_64-dvd.iso"
os_iso_path         = "os/redhat/7"

# OS Meta Data
os_family           = "Linux"
os_version          = "RHEL7"

# VM Hardware Settings
vm_firmware         = "efi-secure"
vm_cpu_sockets      = 1
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 16384
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "rhel7_64Guest"
build_username      = "REPLACEWITHUSERNAME"
build_password      = "REPLACEWITHUSERPASS"
rhsm_user           = "REPLACEWITHRHSMUSER"
rhsm_pass           = "REPLACEWITHRHSMPASS"

# Provisioner Settings
script_files        = [ "../../scripts/rhel7-config.sh" ]
inline_cmds         = []

# Packer Settings
http_directory      = "config"
http_file           = "ks.cfg"