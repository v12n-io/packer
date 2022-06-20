# ----------------------------------------------------------------------------
# Name:         win10.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 10 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "en-gb_windows_10_business_editions_version_21h1_updated_aug_2021_x64_dvd_694d89d9.iso"
os_iso_path                     = "os/microsoft/desktop/10"

# OS Meta Data
vm_os_family                    = "Windows"
vm_os_type                      = "Desktop"
vm_os_vendor                    = "Windows"
vm_os_version                   = "10"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_video_ram                    = 131072
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 8192
vm_mem_reserve_all              = false
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 102400
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = true

# VM OS Settings
vm_guestos_type                 = "windows9_64Guest"
build_username                  = "Administrator"
build_password                  = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files                    = [ "scripts/win10-config.ps1" ]
inline_cmds                     = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]