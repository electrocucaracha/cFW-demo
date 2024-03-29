#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2022
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o errexit
set -o nounset
set -o pipefail

if [ -f /etc/netplan/01-netcfg.yaml ]; then
    sed -i "s/addresses: .*/addresses: [1.1.1.1, 8.8.8.8, 8.8.4.4]/g" /etc/netplan/01-netcfg.yaml
    netplan apply
fi

if ! command -v curl; then
    # shellcheck disable=SC1091
    source /etc/os-release || source /usr/lib/os-release
    case ${ID,,} in
    ubuntu | debian)
        sudo apt-get update -qq >/dev/null
        sudo apt-get install -y -qq -o=Dpkg::Use-Pty=0 curl
        ;;
    esac
fi
