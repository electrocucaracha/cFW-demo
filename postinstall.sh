#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2018
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

set -o nounset
set -o pipefail
set -o xtrace

# install_docker_compose() - Installs docker compose python module
function install_docker_compose {
    if command -v docker-compose; then
        return
    fi
    if ! command -v pip; then
        curl -sL https://bootstrap.pypa.io/get-pip.py | python
    fi
    sudo pip install docker-compose
}

echo 'vm.nr_hugepages = 1024' >> /etc/sysctl.conf
sysctl -p

curl -fsSL http://bit.ly/install_pkg | PKG=docker bash
install_docker_compose

sudo docker build --no-cache -t electrocucaracha/vpp:latest -f vpp/Dockerfile vpp
sudo docker-compose up -d
