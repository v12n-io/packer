# Packer
This repository contains Packer builds for many common OSs running as guests on a vSphere platform. As of Packer v1.7.0, HashiCorp Configuration Language (HCL) is fully supported and so all of the builds in this repository have been updated to use HCL instead of JSON. As such it is possible that some of the templates may not function correctly when using a version of Packer <1.7.0.
From September 2021, required versions have been included in each of the builds. This will require Packer and any required plugins to be at certain versions for the build to execute.

## Version History
* 21.09.1 - Added Windows 2022 and reconfigured Cloudbase-Init for VMwareGuestInfoService. 
* 21.09 - First numbered version. Minimum Packer and plugin versions specified. VM firmware updated to EFI secure where possible.
## Structure
The following is a tree view of the files in this repository:
```
├── LICENSE
├── README.md
├── builds
│   ├── common.pkrvars.hcl
│   ├── vsphere.pkrvars.hcl
│   ├── centos7
│   │   ├── centos7.pkr.hcl
│   │   ├── config
│   │   │   └── ks.cfg
│   │   └── variables.auto.pkrvars.hcl
│   ├── centos8
│   │   ├── centos8.pkr.hcl
│   │   ├── config
│   │   │   └── ks.cfg
│   │   └── variables.auto.pkrvars.hcl
│   ├── photon4
│   │   ├── config
│   │   │   ├── packages_minimal.json
│   │   │   └── photon4.json
│   │   ├── photon4.pkr.hcl
│   │   └── variables.auto.pkrvars.hcl
│   ├── rhel8
│   │   ├── config
│   │   │   └── ks.cfg
│   │   ├── rhel8.pkr.hcl
│   │   └── variables.auto.pkrvars.hcl
│   ├── win10vdi
│   │   ├── config
│   │   │   └── Autounattend.xml
│   │   ├── variables.auto.pkrvars.hcl
│   │   └── win10vdi.pkr.hcl
│   ├── win2016
│   │   ├── config
│   │   │   ├── std
│   │   │   │   └── Autounattend.xml
│   │   │   └── stdcore
│   │   │       └── Autounattend.xml
│   │   ├── variables.auto.pkrvars.hcl
│   │   └── win2016.pkr.hcl
│   ├── win2019
│   │   ├── config
│   │   │   ├── std
│   │   │   │   └── Autounattend.xml
│   │   │   └── stdcore
│   │   │       └── Autounattend.xml
│   │   ├── variables.auto.pkrvars.hcl
│   │   └── win2019.pkr.hcl
│   └── win2022
│       ├── config
│       │   ├── std
│       │   │   └── Autounattend.xml
│       │   └── stdcore
│       │       └── Autounattend.xml
│       ├── variables.auto.pkrvars.hcl
│       └── win2022.pkr.hcl
└── scripts
    ├── centos7-config.sh
    ├── centos8-config.sh
    ├── photon4-config.sh
    ├── rhel8-config.sh
    ├── win10vdi-config.ps1
    ├── win10vdi-initialise.ps1
    ├── win2016-config.ps1
    ├── win2016-initialise.ps1
    ├── win2019-config.ps1
    ├── win2019-initialise.ps1
    ├── win2022-config.ps1
    └── win2022-initialise.ps1
```

The files are divided in to two main directories.
* The "builds" directory contains the build definitions and variables used by Packer.
* The "scripts" directory contains scripts that are used to further customise the builds.

All of the files in this repository have been de-personalised as much as possible, with sensitive or environment-specific information replaced with placeholder text. Luckily those placeholders can be easily changed. That topic will be covered later.
Within the "builds" folder there are two variable definitions files that provide common values to all of the builds:
#### common.pkrvars.hcl
This file contains variables that configure some of the Packer functionality and some elements of build customisation. The values in this file can be altered if desired.
```
# Boot Settings
vm_boot_wait        = "2s"
vm_boot_order       = "disk,cdrom"

# Build Settings
build_repo          = "https://github.com/v12n.io/packer"
build_branch        = "BUILD_BRANCH"

# Packer Settings
http_port_min       = 8000
http_port_max       = 8050
```

#### vsphere.pkrvars.hcl
This file contains variables that tell Packer how to connect to vCenter and common vSphere objects such as datastores etc. The values in this file should be customised to match your environment.
```
# vCenter Settings
vcenter_username        = "VCENTER_USER"
vcenter_password        = "VCENTER_PASS"

# vCenter Configuration
vcenter_server          = "VCENTER_SERVER"
vcenter_datacenter      = "VCENTER_DC"
vcenter_cluster         = "VCENTER_CLUSTER"
vcenter_datastore       = "VCENTER_DS"
vcenter_network         = "VCENTER_NETWORK"
vcenter_iso_datastore   = "VCENTER_ISO_DS"
vcenter_insecure        = true
vcenter_folder          = "Templates"

# VM Settings
vm_cdrom_remove         = true
vm_convert_template     = true
vm_ip_timeout           = "20m"
vm_shutdown_timeout     = "15m"
```

### Builds
Each subfolder contains the build definition and build-specific variables for an OS type and version. As of September 2021 (version 21.09), the following builds are available:
* CentOS 7
* CentOS 8
* Photon 4
* RedHat 8
* Windows 10
* Windows Server 2016 (Desktop Experience and Core)
* Windows Server 2019 (Desktop Experience and Core)

Each build contains the following:
#### variables.auto.pkrvars.hcl
This file is automatically processed by Packer and the variable values made available to the build. An example of the contents of one of these files is provided below.
```
# ISO Settings
os_iso_file         = "rhel-8.4-x86_64-dvd.iso"
os_iso_path         = "os/redhat/8"

# OS Meta Data
os_family           = "Linux"
os_version          = "RHEL8"

# VM Hardware Settings
vm_firmware         = "efi-secure"
vm_cpu_sockets      = 1
vm_cpu_cores        = 1
vm_mem_size         = 2048
vm_nic_type         = "vmxnet3"
vm_disk_controller  = ["pvscsi"]
vm_disk_size        = 16384
vm_disk_thin        = true
vm_cdrom_type       = "sata"

# VM OS Settings
vm_os_type          = "rhel8_64Guest"
build_username      = "REPLACEWITHUSERNAME"
build_password      = "REPLACEWITHUSERPASS"
rhsm_user           = "REPLACEWITHRHSMUSER"
rhsm_pass           = "REPLACEWITHRHSMPASS"

# Provisioner Settings
script_files        = [ "../../scripts/rhel8-config.sh" ]
inline_cmds         = []

# Packer Settings
http_directory      = "config"
http_file           = "ks.cfg"
```
The variable values in this file may need to be changed to suit your requirements. In particular, user names and passwords and paths to ISO files etc.

#### {build}.pkr.hcl
This file contains the build definition that Packer will use. It references the variables supplied from the file above and the two common files to build an OS image. The excerpt of an example RHEL8 file is provided below. It illustrates how the variables are consumed by Packer. Ordinarily it should not be necessary to alter the build file as the majority of configuration is held in one of the variable files.
```
source "vsphere-iso" "rhel8" {
    ...

    # Virtual Machine
    guest_os_type               = var.vm_os_type
    vm_name                     = "rhel8-${ var.build_branch }-${ local.build_version }"
    notes                       = "VER: ${ local.build_version }\nDATE: ${ local.build_date }\nSRC: ${ var.build_repo } (${ var.build_branch })\nOS: RedHat Enterprise Linux 8 Server\nISO: ${ var.os_iso_file }"
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
    ...
```

#### config
This folder contains a file (or sometimes more than one file) that allows the selected operating system to perform an unattended installation. For Linux this is often a kickstart file, and for Windows an Autounattend XML file. Most of these files contain some values that might need altering, depending on your circumstances. For example:
* Default languages
* Keyboard layouts
* Administrative user passwords

All of the files in this repository have been de-personalised as much as possible, with sensitive or environment-specific information replaced with placeholder text. Luckily those placeholders can be easily changed. That topic will be covered later.
### Scripts
The scripts in the "scripts" directory undertake a number of customisation operations. There is no environment specific information held in any of the scripts (hopefully). They may need editing before they are used or customisation is possible by replacing pieces of placholder text. It depends on your use-case!
## Placeholders
To make the various scripts more portable, key configuration items are represented by placeholder text strings. These can easily be replaced with a smattering of grep and sed.
### Example: Replace Admin user password
```
grep -rl 'REPLACEWITHADMINPASS' | xargs sed -i 's/REPLACEWITHADMINPASS/<password>/g'
```
### Example: Replace user credentials
```
grep -rl 'REPLACEWITHUSERNAME' | xargs sed -i 's/REPLACEWITHUSERNAME/<nonrootuser>/g'
grep -rl 'REPLACEWITHUSERPASS' | xargs sed -i 's/REPLACEWITHUSERPASS/<password>/g'
```
### All placeholder replacements
The following list defines all of the placeholder strings that can be replaced using the two examples above as a guide to customise the builds and scripts for your environment:
* REPLACEWITHADMINPASS -- Password for root or Administrator users
* REPLACEWITHUSERNAME -- User name of a non-administrative user to create
* REPLACEWITHUSERPASS -- Password for the non-administrative user
* REPLACEWITHRHSMUSER -- User ID for registering with RedHat Subscription Manager
* REPLACEWITHRHSMPASS -- Password for registering with RedHat Subscription Manager
* REPLACEWITHANSIBLEUSERNAME -- User name of a local account to create for Ansible access
* REPLACEWITHANSIBLEUSERKEY -- SSH public key for Ansible to access
* REPLACEWITHPKISERVER -- HTTP(s) location for downloading Root and Issuing CA certificates (e.g. http://pki.domain.com)
* REPLACEWITHINTRANET -- HTTP(s) location for agent files, configurations etc (e.g. http://intranet.domain.com)
* REPLACEWITHAPPVOLSERVER -- For VDI builds, this is the FQDN of the Horizon AppVols server to register with
* VCENTER_USER -- User name for Packer to connect to vCenter with (e.g. administrator@vsphere.local)
* VCENTER_PASS -- Password for vCenter access
* VCENTER_SERVER -- FQDN of the vCenter server
* VCENTER_DC -- Name of the vSphere Datacenter to build images in
* VCENTER_CLUSTER -- Name of the vSphere Cluster to build images in
* VCENTER_DS -- Name of the vSphere Datastore to build images on (e.g. ds02)
* VCENTER_NETWORK -- Name of the vSphere Network to connect build images to (e.g. network01), that has DHCP enabled
* VCENTER_ISO_DS -- Name of the vSphere Datastore that hosts ISO images (e.g. iso01)
* BUILD_BRANCH -- Used as part of the VM template names that are produced

## Executing Packer
### Validation
Assuming that you've download Packer itself (https://www.packer.io/downloads) and the Windows Update provisioner (https://github.com/rgl/packer-provisioner-windows-update/releases) if required, and that they're located somewhere in your system's path, then validating the build becomes as simple as:
```
cd builds/rhel8
packer init .
packer validate -var-file="../vsphere.pkrvars.hcl" -var-file="../common.pkrvars.hcl" .
```
There should be no errors. (Running "packer init" will check the required versions and plugins are present.)

### Build
Actually executing the build is done using the following:
```
cd builds/rhel8
packer build -var-file="../vsphere.pkrvars.hcl" -var-file="../common.pkrvars.hcl" .
```
Execution time will vary depending on a number of factors such as how current the ISO file is, how many updates are needed, and the steps used in the customisation scripts.