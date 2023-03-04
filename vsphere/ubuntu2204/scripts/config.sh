#!/bin/bash
# Prepare Ubuntu 22.04 LTS template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

## Disable IPv6
#echo 'Disabling IPv6 in grub ...'
#sudo sed -i 's|^\(GRUB_CMDLINE_LINUX.*\)"$|\1 ipv6.disable=1"|' /etc/default/grub
#sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg &>/dev/null

## Apply updates
echo 'Applying package updates ...'
sudo apt-get update -y -q &>/dev/null