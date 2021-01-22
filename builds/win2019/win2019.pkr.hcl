################################################################################
#
# Windows Server 2019 - Packer Template
# @author       Michael Poore
# @website      https://github.com/v12n-io/packer
#
################################################################################

####################
# Sources
####################

# Windows Server 2019 Standard
source "vsphere-iso" "windows-server-2019-std" {

    # vSphere connection settings
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = true

    # vSphere inventory settings
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    datastore                   = var.vcenter_datastore
    folder                      = var.vcenter_folder

    # vSphere Content Library settings
    /*content_library_destination {
        library                 = var.vcenter_content_library
        ovf                     = true
        destroy                 = true
    }*/

    # Virtual Machine basic settings
    vm_name                     = "win2019-std"
    notes                       = "VER: ${var.build_version}\nSRC: ${var.build_repo} (${var.build_branch})\nOS: Windows 2019 STD\nISO: ${var.iso_file}"
    firmware                    = var.vm_firmware
    guest_os_type               = var.vm_guest_type
    tools_upgrade_policy        = true
    remove_cdrom                = true
    convert_to_template         = true

    # Virtual Machine hardware settings
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    CPU_hot_plug                = false
    RAM                         = var.vm_mem_size
    RAM_hot_plug                = false
    cdrom_type                  = var.vm_cdrom_type
    disk_controller_type        = var.vm_disk_controller_type
    storage {
        disk_size               = var.vm_disk_size
        disk_controller_index   = 0
        disk_thin_provisioned   = true
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_network_card
    }
  
    # Removeable media settings
    floppy_files                = var.vm_floppy_files_std
    iso_paths                   = [ "${var.iso_datastore} ${var.iso_path}/${var.iso_file}",
                                    "[] /vmimages/tools-isoimages/windows.iso"
    ]

    # Boot / shutdown settings
    boot_wait                   = var.vm_boot_wait
    boot_command                = var.vm_boot_command
    boot_order                  = "disk,cdrom"
    shutdown_command            = var.vm_shutdown_command
    shutdown_timeout            = "20m"
  
    # Provisioner settings
    ip_wait_timeout             = "20m"
    communicator                = "winrm"
    winrm_username              = var.guest_username
    winrm_password              = var.guest_password
    winrm_port                  = "5985"
    winrm_timeout               = "12h"
}

####################
# Build
####################

build {
    # Define sources
    sources = [
      "source.vsphere-iso.windows-server-2019-std"
    ]

    # Use Windows-Update Provisioner https://github.com/rgl/packer-provisioner-windows-update
    provisioner "windows-update" {
        pause_before = "30s"
        search_criteria = "IsInstalled=0"
        filters = [
            "exclude:$_.Title -like '*VMware*'",
            "exclude:$_.Title -like '*Preview*'",
            "exclude:$_.Title -like '*Defender*'",
            "include:$true"
        ]
    }

    // Uses the PowerShell Provisioner to execute a series of scripts defined in the variables. 
    provisioner "powershell" {
      environment_vars = [
        "BUILD_USERNAME=${var.build_username}"
        ]
      scripts = var.powershell_scripts
    }
}