# ----------------------------------------------------------------------------
# Name:         rhel7.pkr.hcl
# Description:  Build definition for RedHat Enterprise Linux 7
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         29/10/2021
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.7.7"
    required_plugins {
        vsphere = {
            version = ">= v1.0.2"
            source  = "github.com/hashicorp/vsphere"
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
variable "rhsm_user" {
    type        = string
    sensitive   = true
}
variable "rhsm_pass" {
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
variable "http_directory"           { type = string }
variable "http_file"                { type = string }
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
source "vsphere-iso" "rhel7" {
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
    convert_to_template         = var.vm_convert_template

    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "rhel7-${ var.build_branch }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: RedHat Enterprise Linux 7 Server\nISO: ${ var.os_iso_file }"
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
    iso_paths                   = ["[${ var.vcenter_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }"]

    # Boot and Provisioner
    http_directory              = var.http_directory
    http_port_min               = var.http_port_min
    http_port_max               = var.http_port_max
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [ "up", "wait", "e", "<down><down><end><wait>",
                                    "<bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs>",
                                    "quiet text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.http_file}",
                                    "<enter><wait><leftCtrlOn>x<leftCtrlOff>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "ssh"
    ssh_username                = var.build_username
    ssh_password                = var.build_password
    shutdown_command            = "sudo shutdown -P now"
    shutdown_timeout            = var.vm_shutdown_timeout
}

# -------------------------------------------------------------------------- #
#                             Build Management                               #
# -------------------------------------------------------------------------- #
build {
    # Build sources
    sources                 = [ "source.vsphere-iso.rhel7" ]
    
    # Shell Provisioner to execute scripts 
    provisioner "shell" {
        execute_command     = "echo '${var.build_password}' | {{.Vars}} sudo -E -S sh -eu '{{.Path}}'"
        environment_vars    = [ "RHSM_USER=${ var.rhsm_user }",
                                "RHSM_PASS=${ var.rhsm_pass }" ]
        scripts             = var.script_files
    }

    post-processor "manifest" {
        output              = "manifest.txt"
        strip_path          = true
        custom_data         = {
                                vcenter_fqdn    = "${ var.vcenter_server }"
                                vcenter_folder  = "${ var.vcenter_folder }/${ var.os_family }/${ var.os_version }"
                                iso_file        = "${ var.os_iso_file }"
                                build_repo      = "${ var.build_repo }"
                                build_branch    = "${ var.build_branch }"
        }
    }
}