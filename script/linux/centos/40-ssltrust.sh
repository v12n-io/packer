#!/bin/bash
# Install trusted CA certificates
# @author Michael Poore
# @website https://blog.v12n.io

# Variables
pkiServer="REPLACEWITHPKISERVER"
pkiCerts=("rootca.cer" "issuingca.cer")

# Download certificates
cd /etc/pki/ca-trust/source/anchors
for cert in ${pkiCerts[@]}; do
    sudo wget -q $pkiServer/$cert
done

# Update CA trust
update-ca-trust extract