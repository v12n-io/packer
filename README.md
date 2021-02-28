# Packer
This repository contains Packer builds for many common OSs running as guests on a vSphere platform. As of Packer v1.7.0, HashiCorp Configuration Language (HCL) is fully supported and so all of the builds in this repository have been updated to use HCL instead of JSON. As such it is possible that some of the templates may not function correctly when using a version of Packer <1.7.0.
## Structure
The following is a tree view of the file in this repository:
```
├── README.md
├── build
│   ├── linux
│   │   ├── centos7
│   │   │   ├── centos7.pkr.hcl
│   │   │   └── variables.auto.pkrvars.hcl
│   │   ├── centos8
│   │   │   ├── centos8.pkr.hcl
│   │   │   └── variables.auto.pkrvars.hcl
│   │   ├── photon4
│   │   │   ├── photon4.pkr.hcl
│   │   │   └── variables.auto.pkrvars.hcl
│   │   └── ubuntu18
│   │       ├── ubuntu18.pkr.hcl
│   │       └── variables.auto.pkrvars.hcl
│   └── windows
│       ├── win10
│       │   ├── variables.auto.pkrvars.hcl
│       │   └── win10.pkr.hcl
│       ├── win2016
│       │   ├── variables.auto.pkrvars.hcl
│       │   └── win2016.pkr.hcl
│       └── win2019
│           ├── variables.auto.pkrvars.hcl
│           └── win2019.pkr.hcl
├── config
│   ├── linux
│   │   ├── centos7
│   │   │   └── centos7.cfg
│   │   ├── centos8
│   │   │   └── centos8.cfg
│   │   ├── photon4
│   │   │   ├── packages_minimal.json
│   │   │   └── photon4.json
│   │   └── ubuntu18
│   │       └── ubuntu18.cfg
│   └── windows
│       ├── win10
│       │   └── ent
│       │       └── Autounattend.xml
│       ├── win2016
│       │   ├── std
│       │   │   └── Autounattend.xml
│       │   └── stdcore
│       │       └── Autounattend.xml
│       └── win2019
│           ├── std
│           │   └── Autounattend.xml
│           └── stdcore
│               └── Autounattend.xml
├── script
│   ├── linux
│   │   ├── centos
│   │   │   ├── 05-repos.sh
│   │   │   ├── 10-configure-sshd.sh
│   │   │   ├── 20-ansibleuser.sh
│   │   │   ├── 40-ssltrust.sh
│   │   │   ├── 80-cloudinit.sh
│   │   │   ├── 95-motd.sh
│   │   │   └── 99-cleanup.sh
│   │   ├── photon
│   │   │   ├── 00-update.sh
│   │   │   ├── 10-configure-sshd.sh
│   │   │   ├── 95-motd.sh
│   │   │   └── 99-cleanup.sh
│   │   └── ubuntu
│   └── windows
│       ├── 00-vmtools64.cmd
│       ├── 01-initialise.ps1
│       ├── 01-initialisedesktop.ps1
│       ├── 03-systemsettings.ps1
│       ├── 04-tlsconfig.ps1
│       ├── 10-createuser.ps1
│       ├── 40-ssltrust.ps1
│       ├── 60-openssh.ps1
│       ├── 80-ansible.ps1
│       ├── 85-chocolatey.ps1
│       ├── 87-bginfo.ps1
│       ├── 88-horizonagent.ps1
│       ├── 89-horizonosot.ps1
│       ├── 90-cloudinit.ps1
│       ├── 92-sdelete.ps1
│       ├── 95-enablerdp.ps1
│       └── 98-driveletters.ps1
```

The files are divided in to three main directories.
* The "build" directory contains the build definitions and variables used by Packer.
* The "config" directory contains kickstart, preseed, autounattend files etc.
* The "script" directory contains scripts that are used to further customise the builds.

Each of these three directories have subdirectories for Windows and Linux-based builds. Within each of these are separate directories for each OS type and version. (For example, for CentOS 8 the relative path would be build/linux/centos8.) Each template itself is in one of these directories and is named after the OS, e.g. "centos8.pkr.hcl". This file is used by Packer to build / provision the template in to vSphere. Alongside each template will be a file named "variables.auto.pkrvars.hcl". These files contain variable values that Packer will automatically consume.

The files under the "config" directory are used during Packer builds and contain basic settings for the relevant OS. Where potentially sensitive data, such as non-default usernames or passwords, is used there will exist a placeholder. Examples of the placeholders in use are:
* A placeholder string "REPLACEWITHADMINPASS" is used instead of a password for the Administrator or root user.
* A placeholder string "REPLACEWITHUSERNAME" is used instead of a name for a non-root user.
* A placeholder string "REPLACEWITHUSERPASS" is used instead of a password for the non-root user.

The scripts in the "scripts" directory undertake a number of customisation operations. There is no environment specific information held in any of the scripts. Consequently, they need editing before they are used or customisation is possible by replacing pieces of placholder text.

## Environment Variables
These builds assume that some sensitive and environment-specific data is provided by environment variables. The following export command illustrate how these can be created prior to running Packer:

```
export PKR_VAR_vcenter_server="vcenter.fqdn"
export PKR_VAR_vcenter_username="username"
export PKR_VAR_vcenter_password="password"
export PKR_VAR_vcenter_datacenter="datacenter_name"
export PKR_VAR_vcenter_cluster="cluster_name"
export PKR_VAR_vcenter_datastore="datastore_name"
export PKR_VAR_vcenter_network="network_name"
export PKR_VAR_vcenter_iso_datastore="iso_datastore_name"
export PKR_VAR_build_password="password_for_running_scripts"
export PKR_VAR_build_repo="build repository name"
export PKR_VAR_build_branch="build repository branch"
export PKR_VAR_build_http="HTTP location where files from the config directory can be found"
```

**Note: The build_http value is used by Packer to acquire the configuration files for an unattended Linux installation. Therefore DHCP is required to provide the template with an IP address when it first starts and the Packer template assumes that the .cfg file is hosted on the HTTP server.**

As an alternative, the variable values can be included in a var-file and included during Packer execution.

```
# vCenter Credentials
vcenter_username        = "vc_user"
vcenter_password        = "vc_pass"

# vCenter Configuration
vcenter_server          = "vc_fqdn"
vcenter_datacenter      = "dc_name"
vcenter_cluster         = "cls_name"
vcenter_datastore       = "ds_name"
vcenter_network         = "net_name"
vcenter_iso_datastore   = "ds_name"

# VM guest OS
build_username          = "root"
build_password          = "password"
```

## Placeholders
To make the various scripts more portable, key configuration items are represented by placeholder text strings. These can easily be replaced with a smattering of grep and sed.

```
## Replace Admin user password
grep -rl 'REPLACEWITHADMINPASS' | xargs sed -i 's/REPLACEWITHADMINPASS/<password>/g'

## Replace user credentials
grep -rl 'REPLACEWITHUSERNAME' | xargs sed -i 's/REPLACEWITHUSERNAME/<nonrootuser>/g'
grep -rl 'REPLACEWITHUSERPASS' | xargs sed -i 's/REPLACEWITHUSERPASS/<password>/g'

## Replace Ansible user name and key
grep -rl 'REPLACEWITHANSIBLEUSERNAME' | xargs sed -i 's/REPLACEWITHANSIBLEUSERNAME/<ansible_user>/g'
grep -rl 'REPLACEWITHANSIBLEUSERKEY' | xargs sed -i 's|REPLACEWITHANSIBLEUSERKEY|<ansible_ssh_key>|g'

## Replace PKI server
grep -rl 'REPLACEWITHPKISERVER' | xargs sed -i 's/REPLACEWITHPKISERVER/<pki_server_fqdn>/g'
```

## Executing Packer
### Validation
Assuming that you've download Packer itself (https://www.packer.io/downloads) and that it's located somewhere in your system's path, then validating the build becomes as simple as:
```
cd build/linux/centos8
packer validate .
```
This doesn't build the template but it does validate that everything is as it should be. There should be no errors returned. If you need to include extra variable values from a variable file at the base of the structure called "vsphere.pkrvars.hcl", the command becomes:
```
cd build/linux/centos8
packer validate -var-file="../../../vsphere.pkrvars.hcl" .
```
Again, there should be no errors.

### Build
Actually executing the build is done using the following:
```
cd build/linux/centos8
packer build -force .
```
Or, if a variable file is required:
```
cd build/linux/centos8
packer build -var-file="../../../vsphere.pkrvars.hcl" -force .
```
Execution time will vary depending on a number of factors such as how current the OS image is and how many updates are needed.