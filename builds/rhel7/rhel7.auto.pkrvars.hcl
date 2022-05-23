# ----------------------------------------------------------------------------
# Name:         rhel7.auto.pkrvars.hcl
# Description:  Common vSphere variables for RHEL 7 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         04/03/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "rhel-server-7.9-x86_64-dvd.iso"
os_iso_path                     = "ISO"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "RHEL"
vm_os_version                   = "7.9"
vm_os_language                  = "en_GB"
vm_os_keyboard                  = "gb"
vm_os_timezone                  = "Asia/Ho_Chi_Minh"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 4
vm_mem_size                     = 4096
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
vm_guestos_type                 = "rhel7_64Guest"
build_username                  = "REPLACEWITHUSERNAME"
build_password                  = "REPLACEWITHUSERPASS"
rhsm_user                       = "REPLACEWITHRHSMUSER"
rhsm_pass                       = "REPLACEWITHRHSMPASS"

# Provisioner Settings
script_files                    = [ "scripts/rhel7-config.sh" ]
inline_cmds                     = []