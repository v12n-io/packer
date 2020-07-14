#!/bin/bash
# Prepare Photon template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Clear logs
if [ -f /var/log/wtmp ]; then
    cat /dev/null > /var/log/wtmp
fi
if [ -f /var/log/lastlog ]; then
    cat /dev/null > /var/log/lastlog
fi

# Cleanup /tmp directories
rm -rf /tmp/*
rm -rf /var/tmp/*

# Clean Machine ID
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Clean cloud-init
sudo cloud-init clean --logs --seed

# tdnf clean
sudo tdnf clean all

# Cleanup shell history
cat /dev/null > ~/.bash_history && history -c