#!/bin/bash
# Configure SSHd
# @author Michael Poore
# @website https://blog.v12n.io

# Disable root login via SSH
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config

# Enable public key authentication
sudo sed -i "s/.*PubkeyAuthentication.*/PubkeyAuthentication yes/g" /etc/ssh/sshd_config

# Enable password authentication
#sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config