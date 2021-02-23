# ----------------------------------------------------------------------------
# Name:         win10.pkr.hcl
# Description:  Build definition for Windows 10 Desktops
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         21/02/2021
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Variable Definitions                             #
# -------------------------------------------------------------------------- #
# vCenter Credentials
variable "vcenter_username" {
    type        = string
    description = "The username Packer will use to login to vCenter"
    sensitive   = true
}
variable "vcenter_password" {
    type        = string
    description = "The password Packer will use to login to vCenter"
    sensitive   = true
}

# vCenter Configuration
variable "vcenter_server" {
    type        = string
    description = "The FQDN of vCenter"
}
variable "vcenter_datacenter" {
    type        = string
    description = "The name of the vSphere datacenter that Packer will use"
}
variable "vcenter_cluster" {
    type        = string
    description = "The name of the vSphere cluster that Packer will use"
}
variable "vcenter_datastore" {
    type        = string
    description = "The name of the datastore where Packer will create templates"
}
variable "vcenter_network" {
    type        = string
    description = "The name of the network that Packer will attache templates to"
}

# vCenter and ISO Configuration
variable "vcenter_iso_datastore" {
    type        = string
    description = "The name of the datastore where Packer will attach ISO files from"
}
variable "os_iso_file_2004" {
    type        = string
    description = "The name of the ISO file to be used for OS installation"
}
variable "os_iso_file_20h2" {
    type        = string
    description = "The name of the ISO file to be used for OS installation"
}
variable "os_iso_path" {
    type        = string
    description = "The path of the ISO file to be used for OS installation"
}

# OS Meta Data
variable "os_family" {
    type        = string
    description = "The family that guest OS belongs to (e.g. Windows, RedHat or CentOS etc)"
}
variable "os_version" {
    type        = string
    description = "The major version of guest OS that will be installed (e.g. 2019, 8, 4 etc)"
}

# Virtual Machine OS Settings
# See https://vdc-download.vmware.com/vmwb-repository/dcr-public/da47f910-60ac-438b-8b9b-6122f4d14524/16b7274a-bf8b-4b4c-a05e-746f2aa93c8c/doc/vim.vm.GuestOsDescriptor.GuestOsIdentifier.html
variable "vm_os_type" {
    type        = string
    description = "The vSphere guest OS identifier"
}
variable "vm_boot_cmd" {
    type        = list(string)
    description = "The sequence of command / keystrokes required to initiate guest OS boot / install"
}
variable "vm_shutdown_cmd" {
    type        = string
    description = "The command to be issued to shutdown the guest OS"
}

# Virtual Machine Hardware Settings
variable "vm_firmware" {
    type        = string
    description = "The type of firmware for the VM"
    default     = "bios"
}
variable "vm_cpu_sockets" {
    type        = number
    description = "The number of 'physical' CPUs to be configured on the VM"
}
variable "vm_cpu_cores" {
    type        = number
    description = "The number of cores to be configured per CPU on the VM"
}
variable "vm_mem_size" {
    type        = number
    description = "The size of the VM's virtual memory (in Mb)"
}
variable "vm_nic_type" {
    type        = string
    description = "The type of network interface to configure on the VM"
}
variable "vm_disk_controller" {
    type        = list(string)
    description = "A list of the disk controller types to be configured (in order)"
}
variable "vm_disk_size" {
    type        = number
    description = "The size of the VM's system disk (in Mb)"
}
variable "vm_disk_thin" {
    type        = bool
    description = "Indicates if the system disk should be thin provisioned"
}
variable "vm_cdrom_type" {
    type        = string
    description = "The type of CDROM device that should be configured on the VM"
}

# Provisioner Settings
variable "script_files1" {
    type        = list(string)
    description = "A list of scripts defined using relative paths that will be executed against the VM"
}
variable "script_files2" {
    type        = list(string)
    description = "A list of scripts defined using relative paths that will be executed against the VM"
}
variable "inline_cmds1" {
    type        = list(string)
    description = "A list of commands that will be executed against the VM"
}
variable "inline_cmds2" {
    type        = list(string)
    description = "A list of commands that will be executed against the VM"
}

# Build Settings
variable "build_repo" {
    type        = string
    description = "The source control repository used to build the templates"
    default     = "https://github.com/v12n-io/packer"
}
variable "build_branch" {
    type        = string
    description = "The source control repository branch used to build the templates"
    default     = "none"
}
variable "build_username" {
    type        = string
    description = "The guest OS username used to login"
    default     = "Administrator"
    sensitive   = true
}
variable "build_password" {
    type        = string
    description = "The password for the guest OS username"
    sensitive   = true
}

# Local Variables
locals { 
    builddate   = formatdate("YYYYMMDD-hhmm", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
## Windows 10 (2004) - Enterprise Edition
source "vsphere-iso" "w10-2004" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = true
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = "Templates/${ var.os_family }/${ var.os_version }"
    datastore                   = var.vcenter_datastore
    remove_cdrom                = true
    create_snapshot             = true
    convert_to_template         = false
    
    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "w10-2004"
    notes                       = "VER: ${ local.builddate }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows 10 (2004) Enterprise\nISO: ${ var.os_iso_file_2004 }"
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
source "vsphere-iso" "w10-20h2" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = true
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = "Templates/${ var.os_family }/${ var.os_version }"
    datastore                   = var.vcenter_datastore
    remove_cdrom                = true
    create_snapshot             = true
    convert_to_template         = false
    
    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "w10-20h2"
    notes                       = "VER: ${ local.builddate }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: Windows 10 (20H2) Enterprise\nISO: ${ var.os_iso_file_20h2 }"
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
    ip_wait_timeout             = "20m"
    communicator                = "winrm"
    winrm_timeout               = "2h"
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
    sources                 = [ "source.vsphere-iso.w10-2004",
                                "source.vsphere-iso.w10-20h2" ]
    
    # PowerShell Provisioner to execute commands #1
    provisioner "powershell" {
        elevated_user       = var.build_username
        elevated_password   = var.build_password
        inline              = var.inline_cmds1
    }

    # PowerShell Provisioner to execute scripts #1
    provisioner "powershell" {
        elevated_user       = var.build_username
        elevated_password   = var.build_password
        scripts             = var.script_files1
    }

    # Restart Provisioner
    provisioner "windows-restart" {
        pause_before        = "60s"
        restart_timeout     = "30m"
    }
    
    # Windows Update using https://github.com/rgl/packer-provisioner-windows-update
    provisioner "windows-update" {
        pause_before        = "30s"
        search_criteria     = "IsInstalled=0"
        filters             = [ "exclude:$_.Title -like '*VMware*'",
                                "exclude:$_.Title -like '*Preview*'",
                                "exclude:$_.Title -like '*Defender*'",
                                "exclude:$_.InstallationBehavior.CanRequestUserInput",
                                "include:$true" ]
        restart_timeout     = "120m"
    }      
    
    # PowerShell Provisioner to execute scripts #2
    provisioner "powershell" {
        elevated_user       = var.build_username
        elevated_password   = var.build_password
        scripts             = var.script_files2
    }
    
    # PowerShell Provisioner to execute commands #2
    provisioner "powershell" {
        elevated_user       = var.build_username
        elevated_password   = var.build_password
        inline              = var.inline_cmds2
    }
}