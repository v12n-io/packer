#!/bin/bash
# Prepare Photon template for vSphere cloning with updates
# @author Michael Poore
# @website https://blog.v12n.io

# Update existing packages
sudo tdnf update -y -q

# Clean up packages
sudo tdnf clean all