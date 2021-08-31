# Packer
This repository contains Packer builds for many common OSs running as guests on a vSphere platform. As of Packer v1.7.0, HashiCorp Configuration Language (HCL) is fully supported and so all of the builds in this repository have been updated to use HCL instead of JSON. As such it is possible that some of the templates may not function correctly when using a version of Packer <1.7.0.
From September 2021, required versions have been included in each of the builds. This will require Packer and any required plugins to be at certain versions for the build to execute.
## Structure
The following is a tree view of the files in this repository:
```
├── LICENSE
├── README.md
├── builds
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
│   ├── common.pkrvars.hcl
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
│   ├── vsphere.pkrvars.hcl
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
│   └── win2019
│       ├── config
│       │   ├── std
│       │   │   └── Autounattend.xml
│       │   └── stdcore
│       │       └── Autounattend.xml
│       ├── variables.auto.pkrvars.hcl
│       └── win2019.pkr.hcl
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
    └── win2019-initialise.ps1
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
* Windows Server 2016
* Windows Server 2019

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

#### <build>.pkr.hcl
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
Each of these three directories have subdirectories for Windows and Linux-based builds. Within each of these are separate directories for each OS type and version. (For example, for CentOS 8 the relative path would be build/linux/centos8.) Each template itself is in one of these directories and is named after the OS, e.g. "centos8.pkr.hcl". This file is used by Packer to build / provision the template in to vSphere. Alongside each template will be a file named "variables.auto.pkrvars.hcl". These files contain variable values that Packer will automatically consume.

The files under the "config" directory are used during Packer builds and contain basic settings for the relevant OS. Where potentially sensitive data, such as non-default usernames or passwords, is used there will exist a placeholder. Examples of the placeholders in use are:
* A placeholder string "REPLACEWITHADMINPASS" is used instead of a password for the Administrator or root user.
* A placeholder string "REPLACEWITHUSERNAME" is used instead of a name for a non-root user.
* A placeholder string "REPLACEWITHUSERPASS" is used instead of a password for the non-root user.

The scripts in the "scripts" directory undertake a number of customisation operations. There is no environment specific information held in any of the scripts. Consequently, they need editing before they are used or customisation is possible by replacing pieces of placholder text.
## Placeholders
To make the various scripts more portable, key configuration items are represented by placeholder text strings. These can easily be replaced with a smattering of grep and sed.
## Replace Admin user password
```
grep -rl 'REPLACEWITHADMINPASS' | xargs sed -i 's/REPLACEWITHADMINPASS/<password>/g'
```
## Replace user credentials
```
grep -rl 'REPLACEWITHUSERNAME' | xargs sed -i 's/REPLACEWITHUSERNAME/<nonrootuser>/g'
grep -rl 'REPLACEWITHUSERPASS' | xargs sed -i 's/REPLACEWITHUSERPASS/<password>/g'
```
## Replace Ansible user name and key
```
grep -rl 'REPLACEWITHANSIBLEUSERNAME' | xargs sed -i 's/REPLACEWITHANSIBLEUSERNAME/<ansible_user>/g'
grep -rl 'REPLACEWITHANSIBLEUSERKEY' | xargs sed -i 's|REPLACEWITHANSIBLEUSERKEY|<ansible_ssh_key>|g'
```
## Replace PKI server
```
grep -rl 'REPLACEWITHPKISERVER' | xargs sed -i 's/REPLACEWITHPKISERVER/<pki_server_fqdn>/g'
```
## Executing Packer
### Validation
Assuming that you've download Packer itself (https://www.packer.io/downloads) and the Windows Update provisioner (https://github.com/rgl/packer-provisioner-windows-update/releases) if required, and that they're located somewhere in your system's path, then validating the build becomes as simple as:
```
cd build/rhel8
packer init .
packer validate -var-file="../vsphere.pkrvars.hcl" -var-file="../common.pkrvars.hcl" .
```
Again, there should be no errors.

### Build
Actually executing the build is done using the following:
```
cd build/rhel8
packer build -var-file="../vsphere.pkrvars.hcl" -var-file="../common.pkrvars.hcl" .
```
Execution time will vary depending on a number of factors such as how current the OS image is and how many updates are needed.