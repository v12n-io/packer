#!/bin/sh
# Prepare Centos OS template for vSphere cloning with updates
# @author Mark Brookfield
# @modified Michael Poore
# @website https://blog.v12n.io

# Add user and group
sudo groupadd REPLACEWITHANSIBLEUSERNAME
sudo useradd -g REPLACEWITHANSIBLEUSERNAME -G wheel -m -s /bin/bash REPLACEWITHANSIBLEUSERNAME

# Create a random password
echo REPLACEWITHANSIBLEUSERNAME:$(openssl rand -base64 14) | chpasswd

# Configure SSH public key
mkdir /home/REPLACEWITHANSIBLEUSERNAME/.ssh
cat << EOF > /home/REPLACEWITHANSIBLEUSERNAME/.ssh/authorized_keys
REPLACEWITHANSIBLEUSERKEY REPLACEWITHANSIBLEUSERNAME
EOF

chown -R REPLACEWITHANSIBLEUSERNAME:REPLACEWITHANSIBLEUSERNAME /home/REPLACEWITHANSIBLEUSERNAME/.ssh
chmod 700 /home/REPLACEWITHANSIBLEUSERNAME/.ssh
chmod 600 /home/REPLACEWITHANSIBLEUSERNAME/.ssh/authorized_keys