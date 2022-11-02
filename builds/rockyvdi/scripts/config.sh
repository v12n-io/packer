#!/bin/bash
# Prepare Rocky Linux VDI template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Disable IPv6
#echo '-- Disabling IPv6 in grub ...'
#sudo sed -i 's|^\(GRUB_CMDLINE_LINUX.*\)"$|\1 ipv6.disable=1"|' /etc/default/grub
#sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg &>/dev/null

## Apply updates
echo '-- Applying package updates ...'
sudo dnf update -y -q &>/dev/null

## Install core packages
echo '-- Installing additional packages ...'
sudo dnf install -y -q ca-certificates dnf-plugins-core &>/dev/null
sudo dnf install -y -q perl python3 cloud-utils-growpart &>/dev/null

## Adding additional repositories
echo '-- Adding repositories ...'
sudo dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo &>/dev/null

## Cleanup yum
echo '-- Clearing yum cache ...'
sudo dnf clean all &>/dev/null

## Configure SSH server
echo '-- Configuring SSH server daemon ...'
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

## Install trusted SSL CA certificates
echo '-- Installing trusted SSL CA certificates ...'
pkiCerts=("root.crt" "issuing.crt")
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    sudo wget -q ${PKISERVER}/$cert &>/dev/null
done
sudo update-ca-trust extract

## Setup MoTD
echo '-- Setting login banner ...'
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

## Final cleanup actions
echo '-- Executing final cleanup tasks ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
fi
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -f /etc/machine-id
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
echo '-- Configuration complete'