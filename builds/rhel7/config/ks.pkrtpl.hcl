# ----------------------------------------------------------------------------
# Name:         ks.cfg
# Description:  Kickstart File for RHEL7
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         04/03/2022
# ----------------------------------------------------------------------------

# Install Settings
cdrom
text
eula --agreed

# Configurable OS Settings
lang ${vm_os_language}
keyboard ${vm_os_keyboard}
timezone ${vm_os_timezone}

# Network Settings
network --bootproto=dhcp
firewall --enabled --ssh

# Account Settings
rootpw --lock
user --name=${build_username} --plaintext --password=${build_password} --groups=wheel

# Security Settings
auth --passalgo=sha512 --useshadow
selinux --enforcing

# Storage Settings
bootloader --location=mbr
zerombr
clearpart --all --initlabel
part /boot --fstype xfs --size=1024
part /boot/efi --fstype vfat --size=512
part pv.01 --size=1024 --grow
volgroup sysvg pv.01
logvol swap --fstype swap --name=lv_swap --vgname=sysvg --size=8192
logvol / --fstype xfs --name=lv_root --vgname=sysvg --size=16384
logvol /tmp --fstype xfs --name=lv_tmp --vgname=sysvg --size=4096

# Software / Package Settings
skipx
services --enabled=NetworkManager,sshd

%packages --ignoremissing --excludedocs
@core
sudo
open-vm-tools
net-tools
vim
wget
curl
perl
git
yum-utils
unzip
-iwl*firmware
%end

# Post-Install Commands
%post
/usr/sbin/subscription-manager register --username ${rhsm_user} --password ${rhsm_pass} --autosubscribe --force
dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm -y
echo "${build_username} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${build_username}
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
%end

reboot --eject