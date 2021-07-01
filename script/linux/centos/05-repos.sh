#!/bin/bash
# Add extra repositories to prepare Centos OS template for vSphere cloning
# @author Michael Poore
# @website https://blog.v12n.io

# Add SaltStack repo
#yum install https://repo.saltstack.com/py3/redhat/salt-py3-repo-latest.el7.noarch.rpm -y

# Add HashiCorp repo
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# Add epel-release
yum install -y epel-release
