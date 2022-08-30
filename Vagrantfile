# frozen_string_literal: true

# -*- mode: ruby -*-
# vi: set ft=ruby :
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2019,2022
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

no_proxy = ENV["NO_PROXY"] || ENV["no_proxy"] || "127.0.0.1,localhost"
# NOTE: This range is based on vagrant-libvirt network definition CIDR 192.168.121.0/24
(1..254).each do |i|
  no_proxy += ",192.168.121.#{i}"
end
no_proxy += ",10.0.2.15"

Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox

  config.vm.box = "generic/ubuntu2004"
  config.vm.box_check_update = false
  config.vm.synced_folder "./", "/vagrant"
  config.ssh.forward_agent = true

  host = RbConfig::CONFIG["host_os"]
  case host
  when /darwin/
    mem = `sysctl -n hw.memsize`.to_i / 1024
  when /linux/
    mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i
  when /mswin|mingw|cygwin/
    mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i / 1024
  end
  %i[virtualbox libvirt].each do |provider|
    config.vm.provider provider do |p|
      p.cpus = ENV["CPUS"] || 2
      p.memory = ENV["MEMORY"] || (mem / 1024 / 4)
    end
  end

  config.vm.provider "virtualbox" do |v|
    v.gui = false
    v.customize ["modifyvm", :id, "--nictype1", "virtio", "--cableconnected1", "on"]
    # https://bugs.launchpad.net/cloud-images/+bug/1829625/comments/2
    v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
    # Enable nested paging for memory management in hardware
    v.customize ["modifyvm", :id, "--nestedpaging", "on"]
    # Use large pages to reduce Translation Lookaside Buffers usage
    v.customize ["modifyvm", :id, "--largepages", "on"]
    # Use virtual processor identifiers  to accelerate context switching
    v.customize ["modifyvm", :id, "--vtxvpid", "on"]
    # Enable IO APIC
    v.customize ["modifyvm", :id, "--ioapic", "on"]
    # Support for the SSE4.x instruction is required in some versions of VB.
    v.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
    v.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
  end

  config.vm.provider :libvirt do |v, override|
    override.vm.synced_folder "./", "/vagrant", type: "virtiofs"
    v.memorybacking :access, :mode => "shared"
    v.random_hostname = true
    v.management_network_address = "10.0.2.0/24"
    v.management_network_name = "administration"
    # Enable IO APIC
    v.features = ["apic"]
  end

  if !ENV["http_proxy"].nil? && !ENV["https_proxy"].nil? && Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http = ENV["http_proxy"] || ENV["HTTP_PROXY"] || ""
    config.proxy.https    = ENV["https_proxy"] || ENV["HTTPS_PROXY"] || ""
    config.proxy.no_proxy = no_proxy
    config.proxy.enabled = { docker: false, git: false }
  end

  vagrant_root = File.dirname(__FILE__)
  config.vm.provision "shell", path: "#{vagrant_root}/_requirements.sh"
  # Install requirements
  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    # NOTE: Shorten link -> https://github.com/electrocucaracha/pkg-mgr_scripts
    curl -fsSL http://bit.ly/install_pkg | PKG="docker docker-compose" bash
  SHELL

  # Deploy services
  config.vm.provision "shell", inline: <<-SHELL
    set -o pipefail
    set -o errexit

    cd /vagrant
    docker swarm init --advertise-addr 10.0.2.15
    docker build --no-cache -t vpp:21.10.1 --build-arg VERSION=21.10.1 vpp/
    docker-compose up -d
    docker image prune --force
    #curl -X PUT \
    # -H "Authorization: Basic YWRtaW46YWRtaW4=" \
    # -H "Content-Type: application/json" \
    # -H "Cache-Control: no-cache" \
    # -d '{"pg-streams":{"pg-stream": [{"id":"fw_udp1", "is-enabled":"true"},{"id":"fw_udp2", "is-enabled":"true"},{"id":"fw_udp3", "is-enabled":"true"},{"id":"fw_udp4", "is-enabled":"true"},{"id":"fw_udp5", "is-enabled":"true"}]}}' \
    # "http://127.0.0.1:8083/restconf/config/sample-plugin:sample-plugin/pg-streams"
  SHELL
  config.trigger.after :up do |trigger|
    trigger.info = "Traffic sink page:"
    trigger.run_remote = { inline: "curl localhost:667" }
  end
end
