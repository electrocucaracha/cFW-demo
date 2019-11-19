# -*- mode: ruby -*-
# vi: set ft=ruby :
# SPDX-license-identifier: Apache-2.0
##############################################################################
# Copyright (c) 2019
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Apache License, Version 2.0
# which accompanies this distribution, and is available at
# http://www.apache.org/licenses/LICENSE-2.0
##############################################################################

$no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
# NOTE: This range is based on vagrant-libvirt network definition CIDR 192.168.121.0/24
(1..254).each do |i|
  $no_proxy += ",192.168.121.#{i}"
end
$no_proxy += ",10.0.2.15"

Vagrant.configure("2") do |config|
  config.vm.provider :libvirt
  config.vm.provider :virtualbox

  config.vm.box = "elastic/ubuntu-16.04-x86_64"
  config.vm.provision 'shell', privileged: false do |sh|
    sh.inline = <<-SHELL
      cd /vagrant/
      ./postinstall.sh | tee ~/postinstall.log
    SHELL
  end
  config.vm.network :private_network, :ip => "192.168.10.5", :type => :static # unprotected_private_net_cidr
  config.vm.network :private_network, :ip => "192.168.20.5", :type => :static # protected_private_net_cidr
  config.vm.network :private_network, :ip => "10.10.12.5", :type => :static, :netmask => "16", :libvirt__netmask => "255.255.0.0" # onap_private_net_cidr

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy'] || ENV['HTTP_PROXY'] || ""
    config.proxy.https    = ENV['https_proxy'] || ENV['HTTPS_PROXY'] || ""
    config.proxy.no_proxy = ENV['NO_PROXY'] || ENV['no_proxy'] || "127.0.0.1,localhost"
    config.proxy.enabled = { docker: false }
  end

  [:virtualbox, :libvirt].each do |provider|
  config.vm.provider provider do |p|
      p.cpus = 2
      p.memory = 8192
    end
  end
  config.vm.provider 'libvirt' do |v, override|
    v.management_network_address = "192.168.121.0/24"
  end
end
