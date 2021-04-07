# ----------------------------------------------------------------------------
# Name:         win10appv.pkr.hcl
# Description:  Build definition for Windows 10 Desktops
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         21/02/2021
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Variable Definitions                             #
# -------------------------------------------------------------------------- #
# Local Variables
locals { 
    build_version   = formatdate("YYMM", timestamp())
    build_date      = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
## Windows 10 (2004) - Enterprise Edition
source "vsphere-iso" "w10_2004_appv" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = true
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = "Horizon"
    datastore                   = var.vcenter_datastore
    remove_cdrom                = false
    create_snapshot             = true
    convert_to_template         = false
    
    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "w10_2004_appv-${ local.build_version }"
    notes                       = "VER: ${ local.build_version } (${ local.build_date })\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows 10 (2004) Enterprise\nISO: ${ var.os_iso_file_2004 }"
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    RAM                         = var.vm_mem_size
    cdrom_type                  = var.vm_cdrom_type
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_controller_index   = 0
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }
    RAM_reserve_all             = true
    video_ram                   = 128000
    
    # Removeable Media
    floppy_files                = [ "../../../config/windows/win10/ent/Autounattend.xml",
                                    "../../../script/windows/00-vmtools64.cmd",
                                    "../../../script/windows/01-initialisedesktop.ps1" ]
    iso_paths                   = [ "[${ var.vcenter_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file_2004 }",
                                    "[] /vmimages/tools-isoimages/windows.iso" ]
    
    # Boot and Provisioner
    boot_command                = var.vm_boot_cmd
    ip_wait_timeout             = "20m"
    communicator                = "winrm"
    winrm_timeout               = "2h"
    winrm_username              = var.build_username
    winrm_password              = var.build_password
    shutdown_command            = var.vm_shutdown_cmd
    shutdown_timeout            = "15m"
}

## Windows 10 (20H2) - Enterprise Edition
source "vsphere-iso" "w10_20h2_appv" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = true
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = "Horizon"
    datastore                   = var.vcenter_datastore
    remove_cdrom                = true
    convert_to_template         = false
    
    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "w10_20h2_appv-${ local.build_version }"
    notes                       = "VER: ${ local.build_version } (${ local.build_date })\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows 10 (20H2) Enterprise\nISO: ${ var.os_iso_file_20h2 }"
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    RAM                         = var.vm_mem_size
    cdrom_type                  = var.vm_cdrom_type
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_controller_index   = 0
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }
    
    # Removeable Media
    floppy_files                = [ "../../../config/windows/win10/ent/Autounattend.xml",
                                    "../../../script/windows/00-vmtools64.cmd",
                                    "../../../script/windows/01-initialisedesktop.ps1" ]
    iso_paths                   = [ "[${ var.vcenter_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file_20h2 }",
                                    "[] /vmimages/tools-isoimages/windows.iso" ]
    
    # Boot and Provisioner
    boot_command                = var.vm_boot_cmd
    ip_wait_timeout             = "60m"
    communicator                = "winrm"
    winrm_timeout               = "30m"
    winrm_username              = var.build_username
    winrm_password              = var.build_password
    shutdown_command            = var.vm_shutdown_cmd
    shutdown_timeout            = "15m"
}

# -------------------------------------------------------------------------- #
#                             Build Management                               #
# -------------------------------------------------------------------------- #
build {
    # Build sources
    source "source.vsphere-iso.w10_2004_appv" {
        name                = "w10_2004_appv"
    }
    source "source.vsphere-iso.w10_20h2_appv" {
        name                = "w10_20h2_appv"
    }

    # PowerShell Provisioner to execute commands #1
    provisioner "powershell" {
        inline              = [ "powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
                                "Get-AppXPackage -AllUsers | Where {($_.name -notlike \"Photos\") -and ($_.Name -notlike \"Calculator\") -and ($_.Name -notlike \"Store\")} | Remove-AppXPackage -ErrorAction SilentlyContinue",
                                "Get-AppXProvisionedPackage -Online | Where {($_.DisplayName -notlike \"Photos\") -and ($_.DisplayName -notlike \"Calculator\") -and ($_.DisplayName -notlike \"Store\")} | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue" ]
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        pause_before            = "30s"
        restart_timeout         = "30m"
        restart_check_command   = "powershell -command \"& {Write-Output 'restarted.'}\""
    }

    # PowerShell Provisioner to execute scripts #1
    provisioner "powershell" {
        scripts             = [ "../../../script/windows/40-ssltrust.ps1",
                                "../../../script/windows/87-horizonappvols.ps1" ]
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        pause_before            = "30s"
        restart_timeout         = "30m"
        restart_check_command   = "powershell -command \"& {Write-Output 'restarted.'}\""
    }
    
    # PowerShell Provisioner to execute commands #2
    provisioner "powershell" {
        inline              = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]
    }
}