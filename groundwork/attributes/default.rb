if node[:kernel][:machine] == "x86_64"
  arch = "64"
else
  arch = "32"
end

default['groundwork']['gdma_target_server'] = "gdma-autohost"
default['groundwork']['gdma_username'] = "gdma"
default['groundwork']['gdma_protocol'] = "http"
default['groundwork']['gdma_multihost'] = "0"

case platform
  when "ubuntu","debian","redhat","centos","fedora","scientific","amazon"
    default['groundwork']['gdma_client_filename'] = "groundworkagent-2.2.4-61-linux-#{['arch']}-installer.run"
  when "freebsd"
    default['groundwork']['gdma_client_filename'] = "groundworkagent-2.2.4-61-linux-32-installer.run"
  when "windows"
    default['groundwork']['gdma_client_filename'] = "groundworkagent-2.2.4-61-windows-installer.exe"
  else
    default['groundwork']['gdma_client_filename'] = "groundworkagent-2.2.4-61-linux-32-installer.run"
end