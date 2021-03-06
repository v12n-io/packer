# ----------------------------------------------------------------------------
# Name:         variables.auto.pkrvars.hcl
# Description:  Common vSphere variables for Windows 2016 Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         21/02/2021
# ----------------------------------------------------------------------------

# ISO Settings
os_iso_file         = "en_windows_server_2016_updated_feb_2018_x64_dvd_11636692.iso"
os_iso_path         = "os/microsoft/server/2016"

# OS Meta Data
os_family           = "Windows"
os_version          = "2016"

# VM Hardware Settings
vm_cpu_sockets      = 2
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 51200
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "windows9Server64Guest"
vm_boot_cmd         = ["<spacebar>"]
vm_shutdown_cmd     = "shutdown /s /t 10 /f /d p:4:1 /c \"Packer Complete\""

# Provisioner Settings
script_files        = [ "../../../script/windows/03-systemsettings.ps1",
                        "../../../script/windows/04-tlsconfig.ps1",
                        "../../../script/windows/10-createuser.ps1",
                        "../../../script/windows/40-ssltrust.ps1",
                        "../../../script/windows/80-ansible.ps1",
                        "../../../script/windows/95-enablerdp.ps1" ]
inline_cmds         = [ "Get-EventLog -LogName * | ForEach { Clear-EventLog -LogName $_.Log }" ]