# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Ubuntu 20.04 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         03/08/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "ubuntu-20.04.2-live-server-amd64.iso"
os_iso_path         = "os/ubuntu/20"

# OS Meta Data
os_family           = "Linux"
os_version          = "Ubuntu20.04"

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
vm_os_type          = "ubuntu64Guest"

# Provisioner Settings
script_files        = [ "../../../script/linux/centos/05-repos.sh",
                        "../../../script/linux/centos/10-configure-sshd.sh",
                        "../../../script/linux/centos/20-ansibleuser.sh",
                        "../../../script/linux/centos/40-ssltrust.sh",
                        "../../../script/linux/centos/80-cloudinit-7.sh",
                        "../../../script/linux/centos/95-motd.sh",
                        "../../../script/linux/centos/99-cleanup.sh" ]
inline_cmds         = [ "yum update -y",
                        "yum reinstall -y ca-certificates" ]

# Packer Settings
http_directory      = "../../../config/linux/ubuntu20"
http_port_min       = 8000
http_port_max       = 8050