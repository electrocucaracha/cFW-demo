#!/bin/bash
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2020
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

#set -o pipefail
set -o xtrace
#set -o errexit
set -o nounset

function setup_nic {
    local nic=$1
    local tap_nic=$2
    local tap=$3
    local bridge=$4

    ip_addr=$(ip addr show "$nic" | grep inet | awk '{print $2}')
    hw_addr=$(ip -brief link show "$nic" | awk '{print $3;}')
    fake_hw_addr=$(
        echo -n 00
        dd bs=1 count=5 if=/dev/urandom 2>/dev/null | hexdump -v -e '/1 ":%02X"'
    )

    # Change MAC address of nic
    ip link set dev "$nic" down
    ip link set dev "$nic" address "$fake_hw_addr"
    #ip addr flush dev "$nic"
    ip link set dev "$nic" up

    vppctl tap connect "$tap_nic" hwaddr "$hw_addr"
    vppctl set int ip address "$tap" "$ip_addr"
    vppctl set int state "$tap" up
    brctl addbr "$bridge"
    brctl addif "$bridge" "$tap_nic"
    brctl addif "$bridge" "$nic"
    ip link set dev "$bridge" up
}

# Ensure VPP connection
attempt_counter=0
max_attempts=5
until vppctl show ver; do
    if [ ${attempt_counter} -eq ${max_attempts} ]; then
        echo "Max attempts reached"
        exit 1
    fi
    attempt_counter=$((attempt_counter + 1))
    sleep $((attempt_counter * 2))
done

# Configure VPP for vFirewall
setup_nic eth0 tap111 tap-0 br0
setup_nic eth1 tap222 tap-1 br1
brctl show
vppctl show hardware
vppctl show int addr

# Start HoneyComb
#/opt/honeycomb/honeycomb &>/dev/null &disown
/opt/honeycomb/honeycomb

# Start VES client
#/opt/VESreporting/vpp_measurement_reporter "$DCAE_COLLECTOR_IP" "$DCAE_COLLECTOR_PORT" eth1
