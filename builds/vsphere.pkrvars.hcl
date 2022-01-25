# ----------------------------------------------------------------------------
# Name:         vsphere.pkrvars.hcl
# Description:  Common vSphere variables for Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# vCenter Settings
vcenter_username        = "VCENTER_USER"
vcenter_password        = "VCENTER_PASS"

# vCenter Configuration
vcenter_server          = "VCENTER_SERVER"
vcenter_datacenter      = "VCENTER_DC"
vcenter_cluster         = "VCENTER_CLUSTER"
vcenter_datastore       = "VCENTER_DS"
vcenter_network         = "VCENTER_NETWORK"
vcenter_iso_datastore   = "VCENTER_ISO_DS"
vcenter_insecure        = true
vcenter_folder          = "Templates"

# VM Settings
vm_ip_timeout           = "20m"
vm_shutdown_timeout     = "15m"

# Content Library Settings
vcenter_cl_name         = "VCENTER_CL"
vcenter_cl_base_name    = "v12n"