# ----------------------------------------------------------------------------
# Name:         common.pkrvars.hcl
# Description:  Common variables for Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         04/08/2021
# ----------------------------------------------------------------------------

# Boot Settings
vm_boot_wait        = "2s"
vm_boot_order       = "disk,cdrom"

# Build Settings
build_repo          = "https://github.com/v12n.io/packer"
build_branch        = "BUILD_BRANCH"

# Packer Settings
http_port_min       = 8000
http_port_max       = 8050