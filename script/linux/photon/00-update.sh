#!/bin/bash
# Prepare Photon OS template for vSphere cloning with updates
# @author Michael Poore
# @website https://blog.v12n.io

# Update existing packages
tdnf upgrade tdnf -y --refresh 2>&-
tdnf distro-sync -y 2>&-