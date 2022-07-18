# ----------------------------------------------------------------------------
# Name:         win2022.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 2022 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "en-us_windows_server_2022_updated_june_2022_x64_dvd_ac918027.iso"
os_iso_path                     = "os/microsoft/server/2022"

# OS Meta Data
vm_os_family                    = "Windows"
vm_os_type                      = "Server"
vm_os_vendor                    = "Microsoft"
vm_os_version                   = "2022"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_cpu_sockets                  = 1
vm_cpu_cores                    = 1
vm_mem_size                     = 2048
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["lsilogic"]
vm_disk_size                    = 51200
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = true
vcenter_content_library_destroy = true

# VM OS Settings
vm_guestos_type                 = "windows2019srvNext_64Guest"
vm_guestos_language             = "en-GB"
vm_guestos_keyboard             = "en-GB"
vm_guestos_timezone             = "UTC"
vm_guestos_image_core           = "Windows Server 2022 SERVERSTANDARDCORE"
vm_guestos_image_dexp           = "Windows Server 2022 SERVERSTANDARD"
vm_guestos_product_key          = "VDYBN-27WPP-V4HQT-9VMD4-VMK7H"
vm_guestos_owner_name           = "v12n"
vm_guestos_owner_org            = "v12n"
admin_password                  = "REPLACEWITHADMINPASS"
build_username                  = "v12n"
build_password                  = "REPLACEWITHUSERPASS"

# Provisioner Settings
script_files                    = [ "scripts/win2022-config.ps1" ]
inline_cmds                     = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]