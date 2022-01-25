# ----------------------------------------------------------------------------
# Name:         win11vdi.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 11 VDI Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file                     = "en-gb_windows_11_business_editions_updated_jan_2022_x64_dvd_64151dde.iso"
os_iso_path                     = "os/microsoft/desktop/11"

# OS Meta Data
vm_os_family                    = "Windows"
vm_os_type                      = "Desktop"
vm_os_vendor                    = "Windows"
vm_os_version                   = "11"

# VM Hardware Settings
vm_firmware                     = "efi-secure"
vm_video_ram                    = 131072
vm_cpu_sockets                  = 2
vm_cpu_cores                    = 1
vm_mem_size                     = 8192
vm_mem_reserve_all              = true
vm_nic_type                     = "vmxnet3"
vm_disk_controller              = ["pvscsi"]
vm_disk_size                    = 102400
vm_disk_thin                    = true
vm_cdrom_type                   = "sata"
vm_vtpm                         = true

# VM Settings
vm_cdrom_remove                 = true
vcenter_convert_template        = false
vcenter_content_library_ovf     = false
vcenter_content_library_destroy = false
vcenter_snapshot                = true
vcenter_snapshot_name           = "VDI snapshot"

# VM OS Settings
vm_guestos_type                 = "windows9_64Guest"
build_username                  = "Administrator"
build_password                  = "REPLACEWITHADMINPASS"

# Provisioner Settings
script_files                    = [ "scripts/win11vdi-config.ps1" ]
inline_cmds                     = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]