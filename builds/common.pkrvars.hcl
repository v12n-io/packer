# ----------------------------------------------------------------------------
# Name:         common.pkrvars.hcl
# Description:  Common variables for Packer builds
# Author:       Michael Poore (@mpoore)
# URL:          https://github.com/v12n-io/packer
# Date:         24/01/2022
# ----------------------------------------------------------------------------

# Build Settings
build_repo          = "https://vcf.local"
build_branch        = "DEV"

# Packer HTTP Settings
http_port_min       = 8000
http_port_max       = 8050