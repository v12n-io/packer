#!/bin/bash
# Prepare Rocky Linux VDI template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Disable IPv6
echo '-- Disabling IPv6 in grub ...'
echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX ipv6.disable=1"' &>/dev/null | sudo tee -a /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg &>/dev/null
sudo grub2-mkconfig -o /boot/efi/EFI/rocky/grub.cfg &>/dev/null

## Apply updates
echo '-- Setting hostname ...'
sudo hostnamectl set-hostname rockyvdi

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

## Install Horizon Agent
echo '-- Installing Horizon Agent ...'
sudo wget -q ${INTRANETSERVER}/${HORIZONPATH}/${HORIZONAGENT} &>/dev/null
sudo rpm -i ${HORIZONAGENT} &>/dev/null
sleep 10s

## Configure Horizon Agent
echo '-- Configuring Horizon Agent ...'
sudo cat << AGENT > /etc/vmware/viewagent-custom.conf
#Enable/Disable SSO. Default is TRUE
SSOEnable=TRUE

#Set the User ID format for SSO. Default is [username]. If the separator contains special char, you need escape it.
SSOUserFormat=[username]@[domain]

#Set a subnet which other machines can connect to ViewAgent with it. If there are more than one
#local IP with different subnets, the local IP in the configured subnet will be used for ViewAgent.
#You need specify the value in IP/CIDR format, such as Subnet=192.168.1.0/24
Subnet=REPLACEWITHSUBNET

#Set the run once script which will be executed as root permission when the agent
#service starts and host name has been changed since agent installation.
#The specified script will be executed once only after the 1st host name change.
#The option can be used to re-join the cloned VM to AD. Take winbind solution for
#example, you should join the base VM to AD with winbind, and set this option to
#a script path, which should contain domain re-join command, such as:
#"/usr/bin/net ads join -U <YourADUserName>%<ADUserPassword>". After VM Clone, the
#OS customization will change the host name. After that, when agent service starts,
#the script will be executed to join the cloned VM to AD.
RunOnceScript=/root/join.sh

#Set the timeout time in seconds for RunOnceScript execute. Default is 120s.
#RunOnceScriptTimeout=120

#Select the desktop environment if installed in Ubuntu 14.04/16.04/18.04, RHEL/CentOS 7.
SSODesktopType=UseGnomeClassic

#Enable/Disable Keyboard layout sync, default is TRUE
KeyboardLayoutSync=FALSE

#Set the Netbios domain name if this agent have joined domain.
#Please set the Netbios domain name, not DNS domain name. For
#example, if the DNS domain name is yourdomain.com, and the Netbios
#domain name is YOURDOMAIN, you should set YOURDOMAIN.
NetbiosDomain=REPLACEWITHNETBIOS
AGENT
sudo sed -i -r "s|REPLACEWITHSUBNET|$HORIZONSUBNET|g" /etc/vmware/viewagent-custom.conf
sudo sed -i -r "s|REPLACEWITHNETBIOS|$HORIZONNETBIOS|g" /etc/vmware/viewagent-custom.conf

sudo cat << JOIN > /root/join.sh
#!/bin/bash

# Discover the domain
realm discover REPLACEWITHDOMAIN

# Join to the domain
echo 'REPLACEWITHPASSWORD' | realm join -v --computer-ou='REPLACEWITHOU' -U REPLACEWITHUSER REPLACEWITHDOMAIN

# Configure /etc/sssd/sssd.conf
sed -i "s/cache_credentials = True/cache_credentials = False/g" /etc/sssd/sssd.conf
JOIN
sudo chmod 700 /root/join.sh &>/dev/null
sudo sed -i -r "s|REPLACEWITHDOMAIN|$HORIZONDOMAIN|g" /root/join.sh
sudo sed -i -r "s|REPLACEWITHPASSWORD|$HORIZONPASS|g" /root/join.sh
sudo sed -i -r "s|REPLACEWITHUSER|$HORIZONUSER|g" /root/join.sh
sudo sed -i -r "s|REPLACEWITHOU|$HORIZONOU|g" /root/join.sh

sudo sed -i -r "s|#Clipboard.Direction=1|Clipboard.Direction=1|g" /etc/vmware/config

## Disable Gnome Autostart
echo 'X-GNOME-Autostart-enabled=false' &>/dev/null | sudo tee -a /etc/xdg/autostart/gnome-initial-setup-first-login.desktop

## Final cleanup actions
echo '-- Executing final cleanup tasks ...'
if [ -f /etc/udev/rules.d/70-persistent-net.rules ]; then
    sudo rm -f /etc/udev/rules.d/70-persistent-net.rules
fi
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*
sudo rm -f /etc/machine-id
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