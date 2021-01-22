################################################################################
#
# Common variables for Windows Server 2019
# @author       Michael Poore
# @website      https://github.com/v12n-io/packer
#
################################################################################

####################
# Variables
####################

# vCenter settings
vcenter_server              = env("VSPHEREVCENTER")
vcenter_username            = env("VSPHEREUSER")
vcenter_password            = env("VSPHEREPASS")
vcenter_datacenter          = env("VSPHEREDATACENTER")
vcenter_cluster             = env("VSPHERECLUSTER")
vcenter_datastore           = env("VSPHEREDATASTORE")
vcenter_network             = env("VSPHERENETWORK")
vcenter_folder              = "Templates/Windows"

# Build settings
build_version               = env("BUILDVERSION")
build_repo                  = env("BUILDREPO")
build_branch                = env("BUILDBRANCH")

# Virtual Machine basic settings
vm_firmware                 = "bios"
vm_guest_type               = "windows9Server64Guest"

# Virtual Machine hardware settings
vm_cdrom_type               = "sata"
vm_cpu_sockets              = 2
vm_cpu_cores                = 1
vm_mem_size                 = 2048
vm_disk_size                = 51200
vm_disk_controller_type     = ["pvscsi"]
vm_network_card             = "vmxnet3"

# Virtual Machine guest settings
guest_username              = "Administrator"
guest_password              = env("WINDOWSPASS")

# Removeable media settings
iso_datastore               = env("VSPHEREISODS")
iso_path                    = "os/microsoft/server/2019"
iso_file                    = "en_windows_server_2019_updated_dec_2020_x64_dvd_36e0f791.iso"
vm_floppy_files_std         = [
                                "../../configs/win2019/std/Autounattend.xml",
                                "../../misc/pvscsi/",
                                "../../scripts/windows/"
                                ]