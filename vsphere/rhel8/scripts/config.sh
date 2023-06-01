#!/bin/bash
# Prepare RedHat Linux 8 template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Disable IPv6
echo 'Disabling IPv6 in grub ...'
sudo sed -i 's|^\(GRUB_CMDLINE_LINUX.*\)"$|\1 ipv6.disable=1"|' /etc/default/grub
sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg &>/dev/null

## Register with RHSM
echo 'Registering with RedHat Subscription Manager ...'
sudo subscription-manager register --username $RHSM_USER --password $RHSM_PASS --auto-attach &>/dev/null

## Apply updates
echo 'Applying package updates ...'
sudo dnf update -y -q &>/dev/null

## Install core packages
echo 'Installing additional packages ...'
sudo dnf install -y -q https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm &>/dev/null
sudo dnf install -y -q ca-certificates &>/dev/null
sudo dnf install -y -q cloud-init perl python3 cloud-utils-growpart &>/dev/null

## Adding additional repositories
echo 'Adding repositories ...'
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo &>/dev/null

## Cleanup yum
echo 'Clearing yum cache ...'
sudo dnf clean all &>/dev/null

## Configure SSH server
echo 'Configuring SSH server daemon ...'
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

## Create Ansible user
echo 'Creating local user for Ansible integration ...'
sudo groupadd $ANSIBLEUSER
sudo useradd -g $ANSIBLEUSER -G wheel -m -s /bin/bash $ANSIBLEUSER
echo $ANSIBLEUSER:$(openssl rand -base64 14) | sudo chpasswd
sudo mkdir /home/$ANSIBLEUSER/.ssh
sudo cat << EOF > /home/$ANSIBLEUSER/.ssh/authorized_keys
$ANSIBLEKEY
EOF
sudo chown -R $ANSIBLEUSER:$ANSIBLEUSER /home/$ANSIBLEUSER/.ssh
sudo chmod 700 /home/$ANSIBLEUSER/.ssh
sudo chmod 600 /home/$ANSIBLEUSER/.ssh/authorized_keys
echo "$ANSIBLEUSER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$ANSIBLEUSER &>/dev/null

## Install trusted SSL CA certificates
echo 'Installing trusted SSL CA certificates ...'
pkiCerts=("root.crt" "issuing.crt")
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    sudo wget -q ${PKISERVER}/$cert &>/dev/null
done
sudo update-ca-trust extract

## Configure cloud-init
echo '-- Configuring cloud-init ...'
sudo cat << CLOUDCFG > /etc/cloud/cloud.cfg.d/99-vmware-guest-customization.cfg
disable_vmware_customization: false
datasource:
  VMware:
    vmware_cust_file_max_wait: 20
CLOUDCFG

## Setup MoTD
echo 'Setting login banner ...'
BUILDDATE=$(date +"%y%m")
RELEASE=$(cat /etc/redhat-release)
DOCS="https://github.com/v12n-io/packer"
sudo cat << ISSUE > /etc/issue

           {__   {__ {_            
{__     {__ {__ {_     {__{__ {__  
 {__   {__  {__      {__   {__  {__
  {__ {__   {__    {__     {__  {__
   {_{__    {__  {__       {__  {__
    {__    {____{________ {___  {__
        
        $RELEASE ($BUILDDATE)
        $DOCS

ISSUE
sudo ln -sf /etc/issue /etc/issue.net

## Unregister from RHSM
echo 'Unregistering from Red Hat Subscription Manager ...'
sudo subscription-manager remove --all &>/dev/null
sudo subscription-manager unregister &>/dev/null
sudo subscription-manager clean &>/dev/null

## Final cleanup actions
echo 'Executing final cleanup tasks ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
fi
sudo rm -f /etc/sysconfig/network-scripts/*
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -f /etc/machine-id
sudo rm -f /var/lib/dbus/machine-id
sudo cloud-init clean --logs --seed
sudo rm -f /etc/ssh/ssh_host_*
if [ -f /var/log/audit/audit.log ]; then
    sudo cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    sudo cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    sudo cat /dev/null > /var/log/lastlog
fi
echo 'Configuration complete'