# ----------------------------------------------------------------------------
# Name:         win11vdi.auto.pkrvars.hcl
# Description:  Required vSphere variables for Windows 11 VDI Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
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
vm_mem_reserve_all              = false
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
vm_guestos_language             = "en-GB"
vm_guestos_keyboard             = "en-GB"
vm_guestos_systemlocale         = "en-GB"
vm_guestos_timezone             = "GMT Standard Time"

# Horizon Desktop Settings
hz_bginfo_path                  = "other/bginfo"                                            # Relative path on the Intranet Server to BG Info files
hz_bginfo_img                   = "v12n-desktop-background.jpg"                             # Desktop background image for BG Info
hz_bginfo_file                  = "Bginfo64.exe"                                            # BG Info EXE file
hz_agent_path                   = "vmware/horizon/2111"                                     # Relative path on the Intranet Server to Horizon Agent files
hz_agent_file                   = "VMware-Horizon-Agent-x86_64-2111.1-8.4.0-19066669.exe"   # Horizon Agent installation file name
hz_appvols_file                 = "AppVolumesAgent.msi"                                   # AppVolumes agent installation file name
hz_fslogix_file                 = "FSLogixAppsSetup.exe"                                    # FSLogix agent installation file name
hz_osot_file                    = "VMwareHorizonOSOptimizationTool-x86_64-1.0_2111.exe"     # Horizon OS Optimization Tool installation file name
hz_osot_template                = "VMware Templates\\Windows 10 and Server 2016 or later"   # OSOT template to be used

# Provisioner Settings
script_files                    = [ "scripts/config.ps1" ]
inline_cmds                     = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]