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