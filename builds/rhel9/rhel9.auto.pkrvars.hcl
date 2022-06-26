# ----------------------------------------------------------------------------
# Name:         rhel9.auto.pkrvars.hcl
# Description:  Common vSphere variables for RHEL 9 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         26/06/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "rhel-baseos-9.0-x86_64-dvd.iso"
os_iso_path                     = "os/redhat/9"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "RHEL"
vm_os_version                   = "9.0"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 1
vm_cpu_cores                    = 1
vm_mem_size                     = 2048
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 16384
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
vm_guestos_type                 = "rhel9_64Guest"
build_username                  = "REPLACEWITHUSERNAME"
build_password                  = "REPLACEWITHUSERPASS"
rhsm_user                       = "REPLACEWITHRHSMUSER"
rhsm_pass                       = "REPLACEWITHRHSMPASS"

# Provisioner Settings
script_files                    = [ "scripts/rhel9-config.sh" ]
inline_cmds                     = []

# Packer Settings
http_directory                  = "config"
http_file                       = "ks.cfg"