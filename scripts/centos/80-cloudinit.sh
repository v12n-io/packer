#!/bin/bash
# Prepare Centos OS template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Install cloud-init
sudo yum install -y cloud-init
# Disable VMware customization to facilitate static IP address assignment
sudo sed -i "s/^disable_vmware_customization: false/disable_vmware_customization: true/" /etc/cloud/cloud.cfg
# Disable network configuration if VMware customization is true
sudo sed -i "/disable_vmware_customization: true/a\\\nnetwork:\n  config: disabled" /etc/cloud/cloud.cfg

# Disable /tmp folder clearing
sudo sed -i "s@q /tmp@#q /tmp@" /usr/lib/tmpfiles.d/tmp.conf

# Make VMtools service dependent on dbus
sudo sed -i "/^After=vgauthd.service/a After=dbus.service" /lib/systemd/system/vmtoolsd.service

# Disable cloud-init
touch /etc/cloud/cloud-init.disabled

# Create cloud-init.sh script
cat << DELAY > /usr/local/bin/cloud-init.sh
sudo rm -f /etc/cloud/cloud-init.disabled
sudo cloud-init init
sleep 20
sudo cloud-init modules --mode config
sleep 20
sudo cloud-init modules --mode final
sudo touch /etc/cloud/cloud-init.disabled
sudo eject --cdrom
DELAY
chmod +rx /usr/local/bin/cloud-init.sh

# Add delay-init to crontab
sudo echo "$(echo '@reboot ( sleep 90 ; sh /usr/local/bin/cloud-init.sh )' ; crontab -l)" | crontab -

# Change default config to enable SSH password auth
if [ -f "/etc/cloud/cloud.cfg" ]; then
   echo "ssh_pwauth not exist. append to EOF"
   sudo sh -c 'echo "ssh_pwauth: true" >> /etc/cloud/cloud.cfg'
fi