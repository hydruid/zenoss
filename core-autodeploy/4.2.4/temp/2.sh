#!/bin/bash

. ~zenoss/zenoss424-srpm_install/variables.sh

# OS compatibility tests
detect-os3 && detect-arch && detect-user

