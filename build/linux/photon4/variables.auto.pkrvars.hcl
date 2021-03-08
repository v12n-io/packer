# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Photon 4 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         22/02/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "photon-4.0-1526e30ba.iso"
os_iso_path         = "os/photon/4"

# OS Meta Data
os_family           = "Linux"
os_version          = "Photon"

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
vm_os_type          = "vmwarePhoton64Guest"

# Provisioner Settings
script_files        = [ "../../../script/linux/photon/00-update.sh",
                        "../../../script/linux/photon/10-configure-sshd.sh",
                        "../../../script/linux/photon/95-motd.sh",
                        "../../../script/linux/photon/99-cleanup.sh" ]
inline_cmds         = [ ]

# Packer Settings
http_directory      = "../../../config/linux/photon4"
http_port_min       = 8000
http_port_max       = 8050