# ----------------------------------------------------------------------------
# Name:         win10vdi.pkr.hcl
# Description:  Build definition for Windows 10
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.7.4"
    required_plugins {
        vsphere = {
            version = ">= v1.0.1"
            source  = "github.com/hashicorp/vsphere"
        }
        windows-update = {
            version = ">= 0.14.0"
            source  = "github.com/rgl/windows-update"
        }
    }
}

# -------------------------------------------------------------------------- #
#                           Variable Definitions                             #
# -------------------------------------------------------------------------- #
# Sensitive Variables
variable "vcenter_username" {
    type        = string
    sensitive   = true
}
variable "vcenter_password" {
    type        = string
    sensitive   = true
}
variable "build_username" {
    type        = string
    sensitive   = true
}
variable "build_password" {
    type        = string
    sensitive   = true
}

# vCenter Configuration
variable "vcenter_server"           { type = string }
variable "vcenter_datacenter"       { type = string }
variable "vcenter_cluster"          { type = string }
variable "vcenter_datastore"        { type = string }
variable "vcenter_network"          { type = string }
variable "vcenter_insecure"         { type = bool }
variable "vcenter_folder"           { type = string }

# vCenter and ISO Configuration
variable "vcenter_iso_datastore"    { type = string }
variable "os_iso_file"              { type = string }
variable "os_iso_path"              { type = string }

# OS Meta Data
variable "os_family"                { type = string }
variable "os_version"               { type = string }

# Virtual Machine OS Settings
variable "vm_os_type"               { type = string }

# Virtual Machine Hardware Settings
variable "vm_firmware"              { type = string }
variable "vm_boot_order"            { type = string }
variable "vm_boot_wait"             { type = string }
variable "vm_cpu_sockets"           { type = number }
variable "vm_cpu_cores"             { type = number }
variable "vm_mem_size"              { type = number }
variable "vm_nic_type"              { type = string }
variable "vm_disk_controller"       { type = list(string) }
variable "vm_disk_size"             { type = number }
variable "vm_disk_thin"             { type = bool }
variable "vm_cdrom_type"            { type = string }
variable "vm_cdrom_remove"          { type = bool }
variable "vm_convert_template"      { type = bool }
variable "vm_ip_timeout"            { type = string }
variable "vm_shutdown_timeout"      { type = string }

# Provisioner Settings
variable "script_files"             { type = list(string) }
variable "inline_cmds"              { type = list(string) }

# Build Settings
variable "build_repo"               { type = string }
variable "build_branch"             { type = string }

# HTTP Settings
variable "http_port_min"            { type = number }
variable "http_port_max"            { type = number }

# Local Variables
locals { 
    build_version   = formatdate("YY.MM", timestamp())
    build_date      = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
source "vsphere-iso" "win10vdi" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = "${ var.vcenter_folder }/${ var.os_family }/${ var.os_version }"
    datastore                   = var.vcenter_datastore
    remove_cdrom                = var.vm_cdrom_remove
    convert_to_template         = false
    create_snapshot             = true

    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "win10vdi-${ var.build_branch }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows 10\nISO: ${ var.os_iso_file }"
    firmware                    = var.vm_firmware
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    RAM                         = var.vm_mem_size
    cdrom_type                  = var.vm_cdrom_type
    disk_controller_type        = var.vm_disk_controller
    storage {
        disk_size               = var.vm_disk_size
        disk_thin_provisioned   = var.vm_disk_thin
    }
    network_adapters {
        network                 = var.vcenter_network
        network_card            = var.vm_nic_type
    }

    # Removeable Media
    iso_paths                   = [ "[${ var.vcenter_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }", "[] /vmimages/tools-isoimages/windows.iso" ]
    floppy_files                = [ "config/Autounattend.xml", "scripts/win10vdi-initialise.ps1" ]

    # Boot and Provisioner
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [ "<spacebar>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "winrm"
    winrm_username              = var.build_username
    winrm_password              = var.build_password
    shutdown_command            = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Complete\""
    shutdown_timeout            = var.vm_shutdown_timeout
}

# -------------------------------------------------------------------------- #
#                             Build Management                               #
# -------------------------------------------------------------------------- #
build {
    # Build sources
    sources                     = [ "source.vsphere-iso.win10vdi" ]

    # PowerShell Provisioner to install RSAT
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        inline                  = [ "powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
                                    "Get-AppXPackage -AllUsers | Where {($_.name -notlike \"Photos\") -and ($_.Name -notlike \"Calculator\") -and ($_.Name -notlike \"Store\")} | Remove-AppXPackage -ErrorAction SilentlyContinue",
                                    "Get-AppXProvisionedPackage -Online | Where {($_.DisplayName -notlike \"Photos\") -and ($_.DisplayName -notlike \"Calculator\") -and ($_.DisplayName -notlike \"Store\")} | Remove-AppXProvisionedPackage -Online -ErrorAction SilentlyContinue",
                                    "Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online" ]
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        restart_timeout         = "30m"
        restart_check_command   = "powershell -command \"& {Write-Output 'restarted.'}\""
    }
    
    # Windows Update using https://github.com/rgl/packer-provisioner-windows-update
    provisioner "windows-update" {
        pause_before            = "30s"
        search_criteria         = "IsInstalled=0"
        filters                 = [ "exclude:$_.Title -like '*VMware*'",
                                    "exclude:$_.Title -like '*Preview*'",
                                    "exclude:$_.Title -like '*Defender*'",
                                    "exclude:$_.InstallationBehavior.CanRequestUserInput",
                                    "include:$true" ]
        restart_timeout         = "120m"
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        pause_before            = "30s"
        restart_timeout         = "30m"
        restart_check_command   = "powershell -command \"& {Write-Output 'restarted.'}\""
    }   
    
    # PowerShell Provisioner to execute scripts 
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        scripts                 = var.script_files
    }

    # PowerShell Provisioner to execute commands
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        inline                  = var.inline_cmds
    }

    post-processor "manifest" {
        output              = "manifest.txt"
        strip_path          = true
        custom_data         = {
                                vcenter_fqdn    = "${ var.vcenter_server }"
                                vcenter_folder  = "${ var.vcenter_folder }/${ var.os_family }/${ var.os_version }"
                                iso_file        = "${ var.os_iso_file }"
                                vdi             = "true"
                                build_repo      = "${ var.build_repo }"
                                build_branch    = "${ var.build_branch }"
        }
    }
}