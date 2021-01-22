# Install trusted root and issuing CA certificates
# @author Michael Poore
# @website https://blog.v12n.io
# @source https://github.com/virtualhobbit
$ErrorActionPreference = "Stop"

$webserver = "REPLACEWITHPKISERVER"
$url = "http://" + $webserver
$certRoot = "rootca.cer"
$certIssuing = "issuingca.cer"

# Get certificates
ForEach ($cert in $certRoot,$certIssuing) {
  Invoke-WebRequest -Uri ($url + "/" + $cert) -OutFile C:\$cert
}

# Import Root CA certificate
Import-Certificate -FilePath C:\$certRoot -CertStoreLocation 'Cert:\LocalMachine\Root'

# Import Issuing CA certificate
Import-Certificate -FilePath C:\$certIssuing -CertStoreLocation 'Cert:\LocalMachine\CA'

# Delete certificates
ForEach ($cert in $certRoot,$certIssuing) {
  Remove-Item C:\$cert -Confirm:$false
}