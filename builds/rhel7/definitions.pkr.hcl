# ----------------------------------------------------------------------------
# Name:         definitions.pkr.hcl
# Description:  Variable definitions for RHEL 7
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Variable Definitions                             #
# -------------------------------------------------------------------------- #
# Sensitive Variables
variable "vcenter_username" {
    type        = string
    description = "Username used by Packer to connect to vCenter"
    sensitive   = true
}
variable "vcenter_password" {
    type        = string
    description = "Password used by Packer to connect to vCenter"
    sensitive   = true
}
variable "build_username" {
    type        = string
    description = "Non-administrative username for this OS"
    sensitive   = true
}
variable "build_password" {
    type        = string
    description = "Password for the non-administrative user"
    sensitive   = true
}
variable "admin_username" {
    type        = string
    description = "Default administrative username for this OS"
    sensitive   = true
    default     = "root"
}
variable "admin_password" {
    type        = string
    description = "Password for the default administrative user"
    sensitive   = true
    default     = "password"
}
variable "rhsm_user" {
    type        = string
    description = "RedHat Subscription Manager username"
    sensitive   = true
}
variable "rhsm_pass" {
    type        = string
    description = "RedHat Subscription Manager password"
    sensitive   = true
}

# vCenter Configuration
variable "vcenter_server" {
    type        = string
    description = "FQDN for the vCenter Server Packer will create this build in"
}
variable "vcenter_insecure" {
    type        = bool
    description = "Validate the SSL connection to vCenter"
    default     = false
}
variable "vcenter_datacenter" {
    type        = string
    description = "Datacenter name in vCenter where the build will be created"
}
variable "vcenter_cluster" {
    type        = string
    description = "Cluster name in vCenter where the build will be created"
}
variable "vcenter_folder" {
    type        = string
    description = "Folder path in vCenter where the build will be created"
}
variable "vcenter_datastore" {
    type        = string
    description = "vSphere datastore where the build will be created"
}
variable "vcenter_network" {
    type        = string
    description = "vSphere network where the build will be created"
}

# vCenter and ISO Configuration
variable "os_iso_datastore" {
    type        = string
    description = "vSphere datastore name where source OS media reside"
}
variable "os_iso_path" {
    type        = string
    description = "Datastore path to the OS media"
}
variable "os_iso_file" {
    type        = string
    description = "OS media file"
}

# OS Meta Data
variable "vm_os_family" {
    type        = string
    description = "The family that the OS belongs to (e.g. 'Windows' or 'Linux')"
}
variable "vm_os_vendor" {
    type        = string
    description = "The vendor or product name for the OS (e.g. 'Photon', 'RHEL', 'CentOS, 'Ubuntu', 'Windows' etc)"
}
variable "vm_os_type" {
    type        = string
    description = "The type of OS (e.g. 'Server' or 'Desktop')"
    default     = "Server"
}
variable "vm_os_version" {
    type        = string
    description = "The major version of the OS (e.g. '7', '8.5', '2022')"
}
variable "vm_os_language" {
    type        = string
    description = "OS language to be configured"
}
variable "vm_os_keyboard" {
    type        = string
    description = "OS keyboard layout to be configured"
}
variable "vm_os_timezone" {
    type        = string
    description = "OS timezone to be configured"
}

# Virtual Machine OS Settings
variable "vm_guestos_type" {
    type        = string
    description = "The type of guest operating system (or guestid) in vSphere"
}

# Virtual Machine Hardware Settings
variable "vm_firmware" {
    type        = string
    description = "Type of VM firmware to use (one of 'efi', 'efi-secure' or 'bios')"
    default     = "efi-secure"
}
variable "vm_hardware_version" {
    type        = number
    description = "Version of VM hardware to use (e.g. '18' or '19' etc)"
    default     = 19
}
variable "vm_boot_order" {
    type        = string
    description = "Set the comma-separated boot order for the VM (e.g. 'disk,cdrom')"
    default     = "disk,cdrom"
}
variable "vm_boot_wait" {
    type        = string
    description = "Set the delay for the VM to wait after booting before the boot command is sent (e.g. '1h5m2s' or '2s')"
    default     = "2s"
}
variable "vm_tools_policy" {
    type        = bool
    description = "Upgrade VM tools on reboot?"
    default     = true
}
variable "vm_cpu_sockets" {
    type        = number
    description = "The number of CPU sockets for the VM"
    default     = 1
}
variable "vm_cpu_cores" {
    type        = number
    description = "The number of cores per CPU socket for the VM"
    default     = 1
}
variable "vm_cpu_hotadd" {
    type        = bool
    description = "Enable CPU hot-add"
    default     = false
}
variable "vm_mem_size" {
    type        = number
    description = "The size of memory in MB for the VM"
    default     = 2048
}
variable "vm_mem_hotadd" {
    type        = bool
    description = "Enable Memory hot-add"
    default     = false
}
variable "vm_cdrom_type" {
    type        = string
    description = "Type of CD-ROM drive to add to the VM (e.g. 'sata' or 'ide')"
    default     = "sata"
}
variable "vm_cdrom_remove" {
    type        = bool
    description = "Remove CD-ROM drives when provisioning is complete?"
    default     = true
}
variable "vm_nic_type" {
    type        = string
    description = "Type of network card for the VM (e.g. 'e1000e' or 'vmxnet3')"
    default     = "vmxnet3"
}
variable "vm_disk_controller" {
    type        = list(string)
    description = "An ordered list of disk controller types to be added to the VM (e.g. one of more of 'pvscsi', 'scsi' etc)"
    default     = ["pvscsi"]
}
variable "vm_disk_size" {
    type        = number
    description = "The size of system disk in MB for the VM"
    default     = 40960
}
variable "vm_disk_thin" {
    type        = bool
    description = "Thin provision the disk?"
    default     = true
}

# vSphere Content Library and Template Configuration
variable "vcenter_convert_template" {
    type        = bool
    description = "Convert the VM to a template?"
    default     = false
}
variable "vcenter_content_library" {
    type        = string
    description = "Name of the vSphere Content Library to export the VM to"
    default     = null
}
variable "vcenter_content_library_ovf" {
    type        = bool
    description = "Export to Content Library as an OVF file?"
    default     = true
}
variable "vcenter_content_library_destroy" {
    type        = bool
    description = "Delete the VM after successfully exporting to a Content Library?"
    default     = true
}
variable "vcenter_content_library_skip" {
    type        = bool
    description = "Skip adding the VM to a Content Library?"
    default     = false
}
variable "vcenter_snapshot" {
    type        = bool
    description = "Create a snapshot of the VM?"
    default     = false
}
variable "vcenter_snapshot_name" {
    type        = string
    description = "Name of the snapshot to be created on the VM"
    default     = "Created by Packer"
}

# Timeout Settings
variable "vm_ip_timeout" {
    type        = string
    description = "Set the timeout for the VM to obtain an IP address (e.g. '1h5m2s' or '2s')"
    default     = "20m"
}
variable "vm_shutdown_timeout" {
    type = string
    description = "Set the timeout for the VM to shutdown after the shutdown command is issued (e.g. '1h5m2s' or '2s')"
    default     = "30m"
}

# Provisioner Settings
variable "script_files" {
    type        = list(string)
    description = "List of OS scripts to execute"
    default     = []
}
variable "inline_cmds" {
    type        = list(string)
    description = "List of OS commands to execute"
    default     = []
}

# Build Settings
variable "build_repo" {
    type        = string
    description = "Source control respository this build comes from"
}
variable "build_branch" {
    type        = string
    description = "Branch of the source control respository this build comes from"
}

# HTTP Settings
variable "http_port_min" {
    type        = number
    description = "Minimum TCP port number to use for the built-in HTTP server"
    default     = 8000
}
variable "http_port_max" {
    type        = number
    description = "Maximum TCP port number to use for the built-in HTTP server"
    default     = 8050
}