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
ip address show

# Configure VPP for vPacketGenerator
setup_nic eth0 tap111 tap-0 br0
vppctl ip route add "$PROTECTED_NET_CIDR" via "$FW_IPADDR"
sleep 1

ip address show
brctl show
vppctl show hardware
vppctl show int addr

# Install packet streams
for i in $(seq 1 10); do
    cat <<EOL >stream_fw_udp
packet-generator new {
  name fw_udp$i
  rate 10
  node ip4-input
  size 64-64
  no-recycle
  data {
    UDP: ${ip_addr%/*} -> $SINK_IPADDR
    UDP: 15320 -> 8080
    length 128 checksum 0 incrementing 1
  }
}
EOL
    vppctl exec stream_fw_udp
done

# Start HoneyComb
/opt/honeycomb/honeycomb &>/dev/null &
disown
sleep 20

# Enable traffic flows
while 'true'; do
    curl -X PUT -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -H "Postman-Token: 9005870c-900b-2e2e-0902-ef2009bb0ff7" -d '{"streams": {"active-streams": 10}}' http://localhost:8183/restconf/config/stream-count:stream-count/streams
    sleep 300
    curl -X PUT -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: application/json" -H "Cache-Control: no-cache" -H "Postman-Token: 9005870c-900b-2e2e-0902-ef2009bb0ff7" -d '{"streams": {"active-streams": 1}}' http://localhost:8183/restconf/config/stream-count:stream-count/streams
    sleep 300
done
