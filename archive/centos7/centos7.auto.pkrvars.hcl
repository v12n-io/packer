# ----------------------------------------------------------------------------
# Name:         centos7.auto.pkrvars.hcl
# Description:  Common vSphere variables for CentOS 7 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "CentOS-7-x86_64-DVD-2009.iso"
os_iso_path                     = "os/centos/7"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "CentOS"
vm_os_version                   = "7"

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
vm_guestos_type                 = "centos7_64Guest"
build_username                  = "REPLACEWITHUSERNAME"
build_password                  = "REPLACEWITHUSERPASS"

# Provisioner Settings
script_files                    = [ "scripts/centos7-config.sh" ]
inline_cmds                     = []

# Packer Settings
http_directory                  = "config"
http_file                       = "ks.cfg"