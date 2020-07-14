#!/bin/bash
# Prepare Centos OS template for vSphere cloning with updates
# @author Michael Poore
# @website https://blog.v12n.io

# Update existing packages
yum update -y

# Reinstall CA certificates
yum reinstall -y ca-certificates