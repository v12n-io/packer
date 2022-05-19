# ----------------------------------------------------------------------------
# Name:         centos8.auto.pkrvars.hcl
# Description:  Common vSphere variables for CentOS 8 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "CentOS-8.5.2111-x86_64-dvd1.iso"
os_iso_path                     = "ISO"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "CentOS"
vm_os_version                   = "8.5"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 4
vm_mem_size                     = 4096
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 16384
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = true
vcenter_content_library_ovf     = false
vcenter_content_library_destroy = false

# VM OS Settings
vm_guestos_type                 = "centos8_64Guest"
build_username                  = "REPLACEWITHUSERNAME"
build_password                  = "REPLACEWITHUSERPASS"

# Provisioner Settings
script_files                    = [ "scripts/centos8-config.sh" ]
inline_cmds                     = []

# Packer Settings
http_directory                  = "config"
http_file                       = "ks.cfg"