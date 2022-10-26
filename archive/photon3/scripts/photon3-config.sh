#!/bin/bash
# Prepare Photon 3 template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Apply updates
echo ' - Updating the guest operating system ...'
sudo tdnf upgrade tdnf -y --refresh 2>&-
sudo tdnf distro-sync -y 2>&-

## Configure SSH server
echo ' - Configuring SSH server daemon ...'
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

## Create Ansible user
echo ' - Creating local user for Ansible integration ...'
sudo groupadd REPLACEWITHANSIBLEUSERNAME
sudo useradd -g REPLACEWITHANSIBLEUSERNAME -G wheel -m -s /bin/bash REPLACEWITHANSIBLEUSERNAME
echo REPLACEWITHANSIBLEUSERNAME:$(openssl rand -base64 14) | sudo chpasswd
sudo mkdir /home/REPLACEWITHANSIBLEUSERNAME/.ssh
sudo cat << EOF > /home/REPLACEWITHANSIBLEUSERNAME/.ssh/authorized_keys
REPLACEWITHANSIBLEUSERKEY
EOF
sudo chown -R REPLACEWITHANSIBLEUSERNAME:REPLACEWITHANSIBLEUSERNAME /home/REPLACEWITHANSIBLEUSERNAME/.ssh
sudo chmod 700 /home/REPLACEWITHANSIBLEUSERNAME/.ssh
sudo chmod 600 /home/REPLACEWITHANSIBLEUSERNAME/.ssh/authorized_keys

## Install trusted SSL CA certificates
echo ' - Installing trusted SSL CA certificates ...'
pkiServer="REPLACEWITHPKISERVER"
pkiCerts=("root.crt" "issuing.crt")
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    sudo wget -q $pkiServer/$cert
done
sudo update-ca-trust extract

## Setup MoTD
OS=$(head -n 1 /etc/photon-release)
BUILD=$(tail -n 1 /etc/photon-release | awk -F"=" '{print (NF>1)? $NF : ""}')
BUILDDATE=$(date +"%y%m")
RELEASE="$OS ($BUILD)"
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
echo ' - Executing final cleanup tasks ...'
sudo echo -n > /etc/machine-id
echo ' - Configuration complete'