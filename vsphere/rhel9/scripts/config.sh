#!/bin/bash
# Prepare RedHat Linux 9 template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Disable IPv6
echo 'Disabling IPv6 in grub ...'
sed -i 's|^\(GRUB_CMDLINE_LINUX.*\)"$|\1 ipv6.disable=1"|' /etc/default/grub
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg &>/dev/null

## Register with RHSM
echo 'Registering with RedHat Subscription Manager ...'
subscription-manager register --username $RHSM_USER --password $RHSM_PASS --auto-attach &>/dev/null

## Apply updates
echo 'Applying package updates ...'
dnf update -y -q &>/dev/null

## Install core packages
echo 'Installing core packages ...'
dnf install -y -q ca-certificates dnf-plugins-core &>/dev/null

## Adding additional repositories
echo 'Adding repositories ...'
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo &>/dev/null
rpm --import https://repo.saltproject.io/salt/py3/redhat/9/x86_64/SALT-PROJECT-GPG-PUBKEY-2023.pub &>/dev/null
curl -fsSL https://repo.saltproject.io/salt/py3/redhat/9/x86_64/latest.repo | tee /etc/yum.repos.d/salt.repo &>/dev/null

## Install additional packages
echo 'Installing additional packages ...'
dnf install -y -q cloud-init perl python3 cloud-utils-growpart salt-minion &>/dev/null

## Cleanup yum
echo 'Clearing dnf cache ...'
dnf clean all &>/dev/null

## Configure SSH server
echo 'Configuring SSH server daemon ...'
sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

## Create Configuration Management user
#echo 'Creating local user for Configuration Management integration ...'
#groupadd $CONFIGMGMTUSER
#useradd -g $CONFIGMGMTUSER -G wheel -m -s /bin/bash $CONFIGMGMTUSER
#echo $CONFIGMGMTUSER:$(openssl rand -base64 14) | chpasswd
#mkdir /home/$CONFIGMGMTUSER/.ssh
#cat << EOF > /home/$CONFIGMGMTUSER/.ssh/authorized_keys
#$CONFIGMGMTKEY
#EOF
#chown -R $CONFIGMGMTUSER:$CONFIGMGMTUSER /home/$CONFIGMGMTUSER/.ssh
#chmod 700 /home/$CONFIGMGMTUSER/.ssh
#chmod 600 /home/$CONFIGMGMTUSER/.ssh/authorized_keys
#echo "$CONFIGMGMTUSER ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers.d/$CONFIGMGMTUSER &>/dev/null

## Install trusted SSL CA certificates
echo 'Installing trusted SSL CA certificates ...'
pkiCerts=("root.crt" "issuing.crt")
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    wget -q ${PKISERVER}/$cert &>/dev/null
done
update-ca-trust extract

## Configure cloud-init
echo '-- Configuring cloud-init ...'
cat << CLOUDCFG > /etc/cloud/cloud.cfg.d/99-vmware-guest-customization.cfg
disable_vmware_customization: false
ssh_pwauth: yes
datasource:
  VMware:
    vmware_cust_file_max_wait: 20
CLOUDCFG
cloud-init clean --logs --seed
sed -i '/^ssh_pwauth/s/0/1/' /etc/cloud/cloud.cfg

## Configure salt-minion
if [ -z "$SALT_MINION" ]
then
echo '-- Configuring salt-minion ...'
cat << MINION > /etc/salt/minion.d/master.conf
$SALT_MINION
MINION
cat << MINION_TIMER > /usr/lib/systemd/system/salt-minion.timer
[Unit]
Description=Timer for the salt-minion service

[Timer]
OnBootSec=1min

[Install]
WantedBy=timers.target
MINION_TIMER
systemctl enable salt-minion.timer
fi

## Setup MoTD
echo 'Setting login banner ...'
BUILDDATE=$(date +"%y%m")
RELEASE=$(cat /etc/redhat-release)
DOCS="https://github.com/v12n-io/packer"
cat << ISSUE > /etc/issue

           {__   {__ {_            
{__     {__ {__ {_     {__{__ {__  
 {__   {__  {__      {__   {__  {__
  {__ {__   {__    {__     {__  {__
   {_{__    {__  {__       {__  {__
    {__    {____{________ {___  {__
        
        $RELEASE ($BUILDDATE)
        $DOCS

ISSUE
ln -sf /etc/issue /etc/issue.net

## Unregister from RHSM
echo 'Unregistering from Red Hat Subscription Manager ...'
subscription-manager remove --all &>/dev/null
subscription-manager unregister &>/dev/null
subscription-manager clean &>/dev/null
rm -rf /var/log/rhsm/*

## Final cleanup actions
echo 'Executing final cleanup tasks ...'
# Udev rules
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    rm -f /etc/udev/rules.d/70-persistent-net.rules
fi
# Temp directories
rm -rf /tmp/*
rm -rf /var/tmp/*
rm -rf /var/cache/dnf/*
# Machine id
truncate -s 0 /etc/machine-id
# SSH keys
rm -f /etc/ssh/ssh_host_*
# Audit logs
if [ -f /var/log/audit/audit.log ]; then
    cat /dev/null > /var/log/audit/audit.log
fi
if [ -f /var/log/wtmp ]; then
    cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    cat /dev/null > /var/log/lastlog
fi
# Clean history
history -cw
echo > ~/.bash_history
rm -fr /root/.bash_history
# Finished
echo 'Configuration complete'