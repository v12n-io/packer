# ----------------------------------------------------------------------------
# Name:         rocky9.auto.pkrvars.hcl
# Description:  Common vSphere variables for Rocky 9 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "Rocky-9.0-x86_64-dvd.iso"
os_iso_path                     = "os/rocky/9"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "Rocky"
vm_os_version                   = "9.0"

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
vm_guestos_type                 = "rhel8_64Guest"
vm_guestos_language             = "en_GB"
vm_guestos_keyboard             = "gb"
vm_guestos_timezone             = "UTC"
build_username                  = "REPLACEWITHUSERNAME"
build_password                  = "REPLACEWITHUSERPASS"

# Provisioner Settings
script_files                    = [ "scripts/rocky9-config.sh" ]
inline_cmds                     = []