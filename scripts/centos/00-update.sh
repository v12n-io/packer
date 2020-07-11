#!/bin/bash
# Prepare Centos OS template for vSphere cloning with updates
# @author Michael Poore
# @website https://blog.v12n.io

# Update existing packages
sudo yum update -y -q

# Clean up packages
sudo yum clean all