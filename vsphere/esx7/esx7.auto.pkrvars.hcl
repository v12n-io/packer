# ----------------------------------------------------------------------------
# Name:         esx7.auto.pkrvars.hcl
# Description:  Common vSphere variables for ESX 7 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "VMware-VMvisor-Installer-7.0U3g-20328353.x86_64.iso"
os_iso_path                     = "os/esxi/7"

# OS Meta Data
vm_os_family                    = "ESXi"
vm_os_type                      = "Hypervisor"
vm_os_vendor                    = "VMware"
vm_os_version                   = "7.0U3G"

# VM Hardware Settings
vm_firmware                     = "efi"
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 8192
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 65536
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
admin_username                  = "root"
vm_guestos_type                 = "vmkernel7Guest"
vm_guestos_keyboard             = "US Default"

# Provisioner Settings
script_files                    = [ ]
inline_cmds                     = [ "sed -i 's#/system/uuid.*##' /etc/vmware/esx.conf",
                                    "/sbin/auto-backup.sh" ]
#####