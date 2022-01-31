# ----------------------------------------------------------------------------
# Name:         win11vdi.pkr.hcl
# Description:  Build definition for Windows 11 VDI
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.7.9"
    required_plugins {
        vsphere = {
            version = ">= v1.0.3"
            source  = "github.com/hashicorp/vsphere"
        }
        windows-update = {
            version = ">= 0.14.0"
            source  = "github.com/rgl/windows-update"
        }
    }
}

# -------------------------------------------------------------------------- #
#                              Local Variables                               #
# -------------------------------------------------------------------------- #
locals { 
    build_version   = formatdate("YY.MM", timestamp())
    build_date      = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
}

# -------------------------------------------------------------------------- #
#                       Template Source Definitions                          #
# -------------------------------------------------------------------------- #
source "vsphere-iso" "win11vdi" {
    # vCenter
    vcenter_server              = var.vcenter_server
    username                    = var.vcenter_username
    password                    = var.vcenter_password
    insecure_connection         = var.vcenter_insecure
    datacenter                  = var.vcenter_datacenter
    cluster                     = var.vcenter_cluster
    folder                      = var.vcenter_folder
    datastore                   = var.vcenter_datastore

    # Content Library and Template Settings
    convert_to_template         = var.vcenter_convert_template
    create_snapshot             = var.vcenter_snapshot
    snapshot_name               = var.vcenter_snapshot_name

    # Virtual Machine
    guest_os_type               = var.vm_guestos_type
    vm_name                     = "${ source.name }-${ var.build_branch }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }"
    firmware                    = var.vm_firmware
    video_ram                   = var.vm_video_ram
    vTPM                        = var.vm_vtpm         
    CPUs                        = var.vm_cpu_sockets
    cpu_cores                   = var.vm_cpu_cores
    CPU_hot_plug                = var.vm_cpu_hotadd
    RAM                         = var.vm_mem_size
    RAM_hot_plug                = var.vm_mem_hotadd
    RAM_reserve_all             = var.vm_mem_reserve_all
    cdrom_type                  = var.vm_cdrom_type
    remove_cdrom                = var.vm_cdrom_remove
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
    iso_paths                   = [ "[${ var.os_iso_datastore }] ${ var.os_iso_path }/${ var.os_iso_file }", "[] /vmimages/tools-isoimages/windows.iso" ]
    floppy_files                = [ "config/Autounattend.xml", "scripts/win11vdi-initialise.ps1" ]

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
    sources                     = [ "source.vsphere-iso.win11vdi" ]

    # PowerShell Provisioner to install RSAT and remove bloat
    provisioner "powershell" {
        elevated_user           = var.build_username
        elevated_password       = var.build_password
        inline                  = [ "powercfg.exe /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c",
                                    "Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Browser.InternetExplorer* | Remove-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Hello.Face* | Remove-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Media.WindowsMediaPlayer* | Remove-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE* | Remove-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Microsoft.Windows.WordPad* | Remove-WindowsCapability -Online",
                                    "Get-WindowsCapability -Name Microsoft.Windows.Wifi* | Remove-WindowsCapability -Online",
                                    "Get-AppxPackage *WindowsAlarms* | Remove-AppxPackage",
                                    "Get-AppxPackage *AV1VideoExtension* | Remove-AppxPackage",
                                    "Get-AppxPackage *WindowsCalculator* | Remove-AppxPackage",
                                    "Get-AppxPackage *Microsoft.549981C3F5F10* | Remove-AppxPackage",
                                    "Get-AppxPackage *WindowsFeedbackHub* | Remove-AppxPackage",
                                    "Get-AppxPackage *HEIFImageExtension* | Remove-AppxPackage",
                                    "Get-AppxPackage *GetHelp* | Remove-AppxPackage",
                                    "Get-AppxPackage *WindowsMaps* | Remove-AppxPackage",
                                    "Get-AppxPackage *MicrosoftEdge* | Remove-AppxPackage",
                                    "Get-AppxPackage *Todos* | Remove-AppxPackage",
                                    "Get-AppxPackage *ZuneVideo* | Remove-AppxPackage",
                                    "Get-AppxPackage *MicrosoftOfficeHub* | Remove-AppxPackage",
                                    "Get-AppxPackage *Paint* | Remove-AppxPackage",
                                    "Get-AppxPackage *ZuneMusic* | Remove-AppxPackage",
                                    "Get-AppxPackage *BingNews* | Remove-AppxPackage",
                                    "Get-AppxPackage *WindowsNotepad* | Remove-AppxPackage",
                                    "Get-AppxPackage *OneDriveSync* | Remove-AppxPackage",
                                    "Get-AppxPackage *People* | Remove-AppxPackage",
                                    "Get-AppxPackage *Windows.Photos* | Remove-AppxPackage",
                                    "Get-AppxPackage *PowerAutomateDesktop* | Remove-AppxPackage",
                                    "Get-AppxPackage *SkypeApp* | Remove-AppxPackage",
                                    "Get-AppxPackage *MicrosoftSolitaireCollection* | Remove-AppxPackage",
                                    "Get-AppxPackage *SpotifyAB.SpotifyMusic* | Remove-AppxPackage",
                                    "Get-AppxPackage *MicrosoftStickyNotes* | Remove-AppxPackage",
                                    "Get-AppxPackage *Teams* | Remove-AppxPackage",
                                    "Get-AppxPackage *WindowsSoundRecorder* | Remove-AppxPackage",
                                    "Get-AppxPackage *BingWeather* | Remove-AppxPackage",
                                    "Get-AppxPackage *WebpImageExtension* | Remove-AppxPackage",
                                    "Get-AppxPackage *Xbox* | Remove-AppxPackage",
                                    "Get-AppxPackage *YourPhone* | Remove-AppxPackage" ]
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
                                vcenter_folder  = "${ var.vcenter_folder }"
                                iso_file        = "${ var.os_iso_file }"
                                vdi             = "true"
                                build_repo      = "${ var.build_repo }"
                                build_branch    = "${ var.build_branch }"
        }
    }
}