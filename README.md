# Packer
This repository contains Packer builds for many common OSs running as guests on a vSphere platform. As of Packer v1.7.0, HashiCorp Configuration Language (HCL) is fully supported and so all of the builds in this repository have been updated to use HCL instead of JSON.
From September 2021, required versions have been included in each of the builds. This will require Packer and any required plugins to be at certain versions for the build to execute.

## Version History
* 22.11 - Major changes:  
            - Archived builds have been moved in to a separate directory. 
            - All configuration files (e.g. Autounattend.xml and ks.config) are now Packer template files that are customised by Packer during execution. There is no more string substitution using grep!  
            - All Linux OS configuration files are supplied using CD ISOs that are dynamically built by Packer. The built-in HTTP server in Packer is no longer used. This requires Packer to have access to a utility that can be used to create these ISO images, such as "xorriso".  
            - Rocky 8 image.  
            - Rocky 9 image.  
            - RHEL 9 image.  
            - ESXi 7 image.  
            - ESXi 8 image.  
            - All sensitive or environment specific settings are now supplied using environment variables.  
            - The file common.pkrvars.hcl is deprecated and will be removed in the next version.  
            - The file vsphere.pkrvars.hcl is deprecated and will be removed in the next version.  
* 22.02 - Several major changes:
            - The folder layout has been updated. All builds are now self-contained; they have all HCL files and scripts under a single directory.
            - Photon 3, Windows 10 and Windows 2016 have been archived.
            - Variable definitions have been moved in to separate HCL files to make the main template files smaller and easier to navigate.
* 21.11 - Minimum Packer version is now 1.7.7. Minimum Packer vSphere plugin is now 1.0.2. Trusted CA cert name changes.
* 21.10.1 - Added manifest post-processors. Windows Server builds with Desktop Experience renamed to *dexp.
* 21.10 - Added RHEL 7 template, plus some other fixes.
* 21.09.1 - Added Windows 2022 and reconfigured Cloudbase-Init for VMwareGuestInfoService. 
* 21.09 - First numbered version. Minimum Packer and plugin versions specified. VM firmware updated to EFI secure where possible.

All of the files in this repository have been de-personalised as much as possible, with sensitive or environment-specific information being supplied through environment variables.
Within the "builds" folder there are two variable definitions files that provide common values to all of the builds:
#### common.pkrvars.hcl
This file contains variables that configure some of the Packer functionality and some elements of build customisation. As noted in the version history, this file is deprecated. It is no longer required and will be removed in the next version.
```
# Build Settings
#build_repo          = "https://github.com/v12n.io/packer"
#build_branch        = "BUILD_BRANCH"

# Packer HTTP Settings
#http_port_min       = 8000
#http_port_max       = 8050
```

#### vsphere.pkrvars.hcl
This file contains variables that tell Packer how to connect to vCenter and common vSphere objects such as datastores etc. As noted in the version history, this file is deprecated. It is no longer required and will be removed in the next version.
```
# vCenter Settings
#vcenter_username                = "VCENTER_USER"
#vcenter_password                = "VCENTER_PASS"

# vCenter Configuration
#vcenter_server                  = "VCENTER_SERVER"
#vcenter_datacenter              = "VCENTER_DC"
#vcenter_cluster                 = "VCENTER_CLUSTER"
#vcenter_datastore               = "VCENTER_DS"
#vcenter_network                 = "VCENTER_NETWORK"
#os_iso_datastore                = "VCENTER_ISO_DS"
#vcenter_insecure                = true
#vcenter_folder                  = "Templates"

# VM Settings
#vm_ip_timeout                   = "20m"
#vm_shutdown_timeout             = "15m"

# Content Library Settings
#vcenter_content_library         = "VCENTER_CL"
```

### Builds
Each subfolder under "build" contains the build definition and build-specific variables for an OS type and version. As of November 2022 (version 22.11), the following builds are available:
* esx7      - VMware vSphere ESXi 7
* esx8      - VMware vSphere ESXi 8
* photon4   - VMware Photon OS 4
* rhel7     - RedHat Enterprise Linux 7
* rhel8     - RedHat Enterprise Linux 8
* rhel9     - RedHat Enterprise Linux 9
* rocky8    - Rocky Linux 8
* rocky9    - Rocky Linux 9
* win11vdi  - Windows 11 Desktop for VMware Horizon VDI
* win2019   - Windows Server 2019 (Desktop Experience and Core)
* win2022   - Windows Server 2022 (Desktop Experience and Core)

Each build contains the following:

#### definitions.pkr.hcl
This file defines the variables used in the build as well as providing a description and, in some cases, a default value.

#### {build}.auto.pkrvars.hcl
This file is automatically processed by Packer and the variable values made available to the build. 
The variable values in this file may need to be changed to suit your requirements. In particular, user names and passwords and paths to ISO files etc.

#### {build}.pkr.hcl
This file contains the build definition that Packer will use. It references the variables supplied from the file above and any environment variables required.

#### config
This folder contains a file that allows the selected operating system to perform an unattended installation. For Linux this is often a kickstart file, and for Windows an Autounattend XML file. Most of these files contain some values that might need altering, depending on your circumstances. For example:
* Default languages
* Keyboard layouts
* Administrative user passwords
The majority of these values have now been surfaced in to the {build}.auto.pkrvars.hcl files for each build.

All of the files in this repository have been de-personalised as much as possible.

#### scripts
The scripts in the "scripts" directory undertake a number of customisation operations. There is no environment specific information held in any of the scripts. Several scripts take values from environment variables passed in by Packer.

## Environment Variables
To make the build files more portable, key configuration values are provided using environment variables. These values must be supplied for Packer to execute the builds correctly.
The enviornment variables are named specifically so that Packer understands that they should be used by the prefix 'PKR_VAR_'. The remainder of the variable name corresponds to a variable used within the build files.

### All environment variables used
The following list shows how environment variables and their values can be exported to be used by Packer running on a Linux system. For passwords and values containing spaces or other special characters it is recommended to enclose the variable and value in single quotes. Some of the items in the list below show this.
* export 'PKR_VAR_admin_password=password'
* export 'PKR_VAR_build_ansible_key=sshkey'
* export 'PKR_VAR_build_ansible_user=sshuser'
* export PKR_VAR_build_branch=dev
* export 'PKR_VAR_build_password=password'
* export PKR_VAR_build_pkiserver=http://pkiserver.domain
* export PKR_VAR_build_repo=https://github.com/v12n-io/packer.git
* export PKR_VAR_build_username=localuser
* export PKR_VAR_os_iso_datastore=ukw-dsiso
* export 'PKR_VAR_rhsm_pass=password'
* export PKR_VAR_rhsm_user=rhsmuser
* export PKR_VAR_vcenter_cluster=cluster
* export PKR_VAR_vcenter_content_library=contentlibraryname
* export PKR_VAR_vcenter_datacenter=datacenter
* export PKR_VAR_vcenter_datastore=datastore
* export PKR_VAR_vcenter_folder=vcenterfolder
* export PKR_VAR_vcenter_network=vcenternetwork
* export 'PKR_VAR_vcenter_password=password'
* export PKR_VAR_vcenter_server=vcenterserver.domain
* export PKR_VAR_vcenter_username=vcenteruser
* export PKR_VAR_intranet_server=http://intranetserver.domain
* export PKR_VAR_hz_appvols_server=appvolsserver.domain

## Executing Packer
### Validation
Assuming that you've download Packer and that they're located somewhere in your system's path, then validating the build becomes as simple as:
```
cd builds/rhel8
packer init .
packer validate .
```
There should be no errors. (Running "packer init" will check the required versions and plugins are present.)

### Build
Actually executing the build is done using the following:
```
cd builds/rhel8
packer build .
```
Execution time will vary depending on a number of factors such as how current the ISO file is, how many updates are needed, and the steps used in the customisation scripts.

## Repository Structure
```
├── LICENSE
├── README.md
├── archive
│   ├── centos7
│   │   ├── centos7.auto.pkrvars.hcl
│   │   ├── centos7.pkr.hcl
│   │   ├── config
│   │   │   └── ks.cfg
│   │   ├── definitions.pkr.hcl
│   │   └── scripts
│   │       └── centos7-config.sh
│   ├── centos8
│   │   ├── centos8.auto.pkrvars.hcl
│   │   ├── centos8.pkr.hcl
│   │   ├── config
│   │   │   └── ks.cfg
│   │   ├── definitions.pkr.hcl
│   │   └── scripts
│   │       └── centos8-config.sh
│   ├── photon3
│   │   ├── config
│   │   │   ├── packages_minimal.json
│   │   │   └── photon3.json
│   │   ├── photon3.pkr.hcl
│   │   ├── scripts
│   │   │   └── photon3-config.sh
│   │   └── variables.auto.pkrvars.hcl
│   ├── win10vdi
│   │   ├── config
│   │   │   └── Autounattend.xml
│   │   ├── scripts
│   │   │   ├── win10vdi-config.ps1
│   │   │   └── win10vdi-initialise.ps1
│   │   ├── variables.auto.pkrvars.hcl
│   │   └── win10vdi.pkr.hcl
│   └── win2016
│       ├── config
│       │   ├── stdcore
│       │   │   └── Autounattend.xml
│       │   └── stddexp
│       │       └── Autounattend.xml
│       ├── definitions.pkr.hcl
│       ├── scripts
│       │   ├── win2016-config.ps1
│       │   └── win2016-initialise.ps1
│       ├── win2016.auto.pkrvars.hcl
│       └── win2016.pkr.hcl
├── builds
│   ├── common.pkrvars.hcl
│   ├── esx7
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── esx7.auto.pkrvars.hcl
│   │   └── esx7.pkr.hcl
│   ├── esx8
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── esx8.auto.pkrvars.hcl
│   │   └── esx8.pkr.hcl
│   ├── photon4
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── photon4.auto.pkrvars.hcl
│   │   ├── photon4.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── rhel7
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── rhel7.auto.pkrvars.hcl
│   │   ├── rhel7.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── rhel8
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── rhel8.auto.pkrvars.hcl
│   │   ├── rhel8.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── rhel9
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── rhel9.auto.pkrvars.hcl
│   │   ├── rhel9.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── rocky8
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── rocky8.auto.pkrvars.hcl
│   │   ├── rocky8.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── rocky9
│   │   ├── bump
│   │   ├── config
│   │   │   └── ks.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── rocky9.auto.pkrvars.hcl
│   │   ├── rocky9.pkr.hcl
│   │   └── scripts
│   │       └── config.sh
│   ├── vsphere.pkrvars.hcl
│   ├── win11vdi
│   │   ├── config
│   │   │   └── Autounattend.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── scripts
│   │   │   ├── config.ps1
│   │   │   └── initialise.ps1
│   │   ├── win11vdi.auto.pkrvars.hcl
│   │   └── win11vdi.pkr.hcl
│   ├── win2019
│   │   ├── config
│   │   │   └── Autounattend.pkrtpl.hcl
│   │   ├── definitions.pkr.hcl
│   │   ├── scripts
│   │   │   ├── config.ps1
│   │   │   └── initialise.ps1
│   │   ├── win2019.auto.pkrvars.hcl
│   │   └── win2019.pkr.hcl
│   └── win2022
│       ├── config
│       │   └── Autounattend.pkrtpl.hcl
│       ├── definitions.pkr.hcl
│       ├── scripts
│       │   ├── config.ps1
│       │   └── initialise.ps1
│       ├── win2022.auto.pkrvars.hcl
│       └── win2022.pkr.hcl
```
