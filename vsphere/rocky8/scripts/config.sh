#!/bin/bash
# Prepare Rocky Linux 8 template for vSphere cloning
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
sudo dnf install -y -q cloud-init perl python3 cloud-utils-growpart &>/dev/null

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

## Create Ansible user
echo '-- Creating local user for Ansible integration ...'
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
echo '-- Installing trusted SSL CA certificates ...'
pkiCerts=("root.crt" "issuing.crt")
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    sudo wget -q ${PKISERVER}/$cert &>/dev/null
done
sudo update-ca-trust extract

## Configure cloud-init
echo '-- Installing cloud-init ...'
sudo touch /etc/cloud/cloud-init.disabled
sudo sed -i 's/^ssh_pwauth:   0/ssh_pwauth:   1/g' /etc/cloud/cloud.cfg
sudo sed -i -e 1,3d /etc/cloud/cloud.cfg
sudo sed -i "s/^disable_vmware_customization: false/disable_vmware_customization: true/" /etc/cloud/cloud.cfg
sudo sed -i "/disable_vmware_customization: true/a\\\nnetwork:\n  config: disabled" /etc/cloud/cloud.cfg
sudo sed -i "s@^[a-z] /tmp @# &@" /usr/lib/tmpfiles.d/tmp.conf
sudo sed -i "/^After=vgauthd.service/a After=dbus.service" /usr/lib/systemd/system/vmtoolsd.service
sudo sed -i '/^disable_vmware_customization: true/a\datasource_list: [OVF]' /etc/cloud/cloud.cfg
sudo cat << RUNONCE > /etc/cloud/runonce.sh
#!/bin/bash
# Runonce script for cloud-init on vSphere
# @author Michael Poore
# @website https://blog.v12n.io

## Enable cloud-init
sudo rm -f /etc/cloud/cloud-init.disabled
## Execute cloud-init
sudo cloud-init init
sleep 20
sudo cloud-init modules --mode config
sleep 20
sudo cloud-init modules --mode final
## Mark cloud-init as complete
sudo touch /etc/cloud/cloud-init.disabled
sudo touch /tmp/cloud-init.complete
sudo crontab -r
RUNONCE
sudo chmod +rx /etc/cloud/runonce.sh
echo "$(echo '@reboot ( sleep 30 ; sh /etc/cloud/runonce.sh )' ; crontab -l)" | sudo crontab -

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
echo '-- Configuration complete'