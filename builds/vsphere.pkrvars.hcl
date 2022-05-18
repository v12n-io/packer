# ----------------------------------------------------------------------------
# Name:         vsphere.pkrvars.hcl
# Description:  Common vSphere variables for Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# vCenter Settings
vcenter_username                = "administrator@vsphere.local"
vcenter_password                = "VCENTER_PASS"

# vCenter Configuration
vcenter_server                  = "vc.hcdlab.local"
vcenter_datacenter              = "HCD-DC01"
vcenter_cluster                 = "HCD-Cluster02"
vcenter_datastore               = "datastore4-r620"
vcenter_network                 = "dvpg-vlan-20"
os_iso_datastore                = "datastore2-r620"
vcenter_insecure                = true
vcenter_folder                  = "Templates"

# VM Settings
vm_ip_timeout                   = "20m"
vm_shutdown_timeout             = "15m"

# Content Library Settings
vcenter_content_library         = "VCENTER_CL"