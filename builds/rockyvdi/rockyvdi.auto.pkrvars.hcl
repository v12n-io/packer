# ----------------------------------------------------------------------------
# Name:         rockyvdi.auto.pkrvars.hcl
# Description:  Common vSphere variables for Rocky VDI Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "Rocky-8.6-x86_64-dvd1.iso"
os_iso_path                     = "os/rocky/8"

# OS Meta Data
vm_os_family                    = "Linux"
vm_os_type                      = "Server"
vm_os_vendor                    = "Rocky"
vm_os_version                   = "8.6"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 8192
vm_video_ram                    = 131072
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 102400
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

# Horizon Desktop Settings
hz_agent_path                   = "vmware/horizon/2111"                                             # Relative path on the Intranet Server to Horizon Agent files
hz_agent_file                   = "VMware-horizonagent-linux-2111.1-8.4.0-19155374.el8.x86_64.rpm"  # Horizon Agent installation file name

# Provisioner Settings
script_files                    = [ "scripts/config.sh" ]
inline_cmds                     = []