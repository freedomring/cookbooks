#
# Cookbook Name:: groundwork
# Recipe:: gdma
#
# Copyright 2012, Graham Trummell
#
# All rights reserved - Do Not Redistribute
#

# Get, install, and start GDMA as long as it's not already installed.
case node.platform
  when "ubuntu","debian","redhat","centos","fedora","scientific","amazon"
    directory "/tmp" do
      action :create
      not_if "test -d /tmp"
    end
    bash "get_install_gdma" do
      code <<-EOH
      cd /tmp
      wget -O /tmp/#{node['groundwork']['gdma_client_filename']} http://#{node['groundwork']['gdma_target_server']}/agents/#{node['groundwork']['gdma_client_filename']}
      chmod 0755 /tmp/#{node['groundwork']['gdma_client_filename']}
      /tmp/#{node['groundwork']['gdma_client_filename']} --unattendedmodeui none --mode unattended --gdma_target_server #{node['groundwork']['gdma_target_server']} --gdma_username #{node['groundwork']['gdma_username']} --gdma_protocol #{node['groundwork']['gdma_protocol']} --multihost #{node['groundwork']['gdma_multihost']}
      EOH
      not_if "test -d /usr/local/groundwork/gdma"
    end
  when "windows"
    directory "C:\temp" do
      action :create
      not_if "test -d C:\temp"
    end
    powershell "get_install_gdma" do
      code <<-EOH
      $source = "http://#{node['groundwork']['gdma_target_server']}/agents/#{node['groundwork']['gdma_client_filename']}"
      $destination = "c:\temp\#{node['groundwork']['gdma_client_filename']}"
      $wc = New-Object System.Net.WebClient
      $wc.DownloadFile($source, $destination)
      "c:\temp\#{node['groundwork']['gdma_client_filename']} --unattendedmodeui none --mode unattended --gdma_target_server #{node['groundwork']['gdma_target_server']} --gdma_username #{node['groundwork']['gdma_username']} --gdma_protocol #{node['groundwork']['gdma_protocol']} --multihost #{node['groundwork']['gdma_multihost']}"
      EOH
      not_if "test -d 'C:\Program Files (x86)\groundwork'"
    end
end

# Now start the service
service "gdma" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :restart ]
  only_if "test -f /etc/init.d/gdma"
end