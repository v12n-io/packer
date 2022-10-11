#!/bin/bash
# Prepare Photon 4 template for vSphere cloning
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

## Install trusted SSL CA certificates
echo ' - Installing trusted SSL CA certificates ...'
pkiCerts=("root.crt" "issuing.crt")
cd /etc/ssl/certs
for cert in ${pkiCerts[@]}; do
    sudo wget -O $cert.pem -q ${PKISERVER}/$cert &>/dev/null
done
sudo /usr/bin/rehash_ca_certificates.sh

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