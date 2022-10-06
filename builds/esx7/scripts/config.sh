#!/bin/bash
# Prepare ESXi 7 template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Clear system UUID
sed -i 's#/system/uuid.*##' /etc/vmware/esx.conf

# Persist the change
/sbin/auto-backup.sh