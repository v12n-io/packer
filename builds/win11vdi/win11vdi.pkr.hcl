# ----------------------------------------------------------------------------
# Name:         win11vdi.pkr.hcl
# Description:  Build definition for Windows 11 VDI
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# ----------------------------------------------------------------------------

# -------------------------------------------------------------------------- #
#                           Packer Configuration                             #
# -------------------------------------------------------------------------- #
packer {
    required_version = ">= 1.8.3"
    required_plugins {
        vsphere = {
            version = ">= v1.0.6"
            source  = "github.com/hashicorp/vsphere"
        }
        windows-update = {
            version = ">= 0.14.1"
            source  = "github.com/rgl/windows-update"
        }
    }
}

# -------------------------------------------------------------------------- #
#                              Local Variables                               #
# -------------------------------------------------------------------------- #
locals { 
    build_version               = formatdate("YY.MM", timestamp())
    build_date                  = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
    floppy_content              = {
                                    "Autounattend.xml" = templatefile("${abspath(path.root)}/config/Autounattend.pkrtpl.hcl", {
                                        admin_password            = var.admin_password
                                        vm_guestos_language       = var.vm_guestos_language
                                        vm_guestos_systemlocale   = var.vm_guestos_systemlocale
                                        vm_guestos_keyboard       = var.vm_guestos_keyboard
                                        vm_guestos_timezone       = var.vm_guestos_timezone
                                        vm_windows_image          = "Enterprise"
                                    })
                                  }
    vm_description              = "VER: ${ local.build_version }\nDATE: ${ local.build_date }"
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
    notes                       = local.vm_description
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
    floppy_files                = [ "scripts/initialise.ps1" ]
    floppy_content              = local.floppy_content

    # Boot and Provisioner
    boot_order                  = var.vm_boot_order
    boot_wait                   = var.vm_boot_wait
    boot_command                = [ "<spacebar>" ]
    ip_wait_timeout             = var.vm_ip_timeout
    communicator                = "winrm"
    winrm_username              = var.admin_username
    winrm_password              = var.admin_password
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
                                    "Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Browser.InternetExplorer* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Hello.Face* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Media.WindowsMediaPlayer* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Microsoft.Windows.PowerShell.ISE* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Microsoft.Windows.WordPad* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-WindowsCapability -Name Microsoft.Windows.Wifi* -Online | Remove-WindowsCapability -Online | Out-Null",
                                    "Get-AppxPackage *WindowsAlarms* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *AV1VideoExtension* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WindowsCalculator* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Microsoft.549981C3F5F10* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WindowsFeedbackHub* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *HEIFImageExtension* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *GetHelp* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WindowsMaps* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Todos* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *ZuneVideo* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *MicrosoftOfficeHub* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Paint* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *ZuneMusic* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *BingNews* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WindowsNotepad* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *OneDriveSync* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage Microsoft.People -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Windows.Photos* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *PowerAutomateDesktop* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *SkypeApp* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *MicrosoftSolitaireCollection* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *SpotifyAB.SpotifyMusic* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *MicrosoftStickyNotes* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Teams* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WindowsSoundRecorder* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *BingWeather* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *WebpImageExtension* -AllUsers | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *Xbox* -AllUsers | Where-Object -Property NonRemovable -eq $false | Remove-AppxPackage | Out-Null",
                                    "Get-AppxPackage *YourPhone* -AllUsers | Remove-AppxPackage | Out-Null" ]
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
        elevated_user           = var.admin_username
        elevated_password       = var.admin_password
        scripts                 = var.script_files
        environment_vars        = [ "PKISERVER=${ var.build_pkiserver }",
                                    "INTRANETSERVER=${ var.intranet_server }",
                                    "BGINFOPATH=${ var.hz_bginfo_path }",
                                    "BGINFOIMG=${ var.hz_bginfo_img }",
                                    "BGINFOFILE=${ var.hz_bginfo_file }",
                                    "HORIZONPATH=${ var.hz_agent_path }",
                                    "HORIZONAGENT=${ var.hz_agent_file }",
                                    "APPVOLSAGENT=${ var.hz_appvols_file }",
                                    "APPVOLSSERVER=${ var.hz_appvols_server }",
                                    "FSLOGIXAGENT=${ var.hz_fslogix_file }",
                                    "OSOTAGENT=${ var.hz_osot_file }",
                                    "OSOTTEMPLATE=${ var.hz_osot_template }" ]
    }

    # PowerShell Provisioner to execute commands
    provisioner "powershell" {
        elevated_user           = var.admin_username
        elevated_password       = var.admin_password
        inline                  = var.inline_cmds
    }

    post-processor "manifest" {
        output                  = "manifest.txt"
        strip_path              = true
        custom_data             = {
            vcenter_fqdn        = var.vcenter_server
            vcenter_folder      = var.vcenter_folder
            iso_file            = var.os_iso_file
            build_repo          = var.build_repo
            build_branch        = var.build_branch
            build_version       = local.build_version
            build_date          = local.build_date
        }
    }
}