#
# Cookbook Name:: smm-clearlogs
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

directory "/root/bin" do
  owner "root"
  group "root"
  mode "0755"
  action :create
  not_if "test -d /root/bin"
end

cookbook_file "/root/bin/smm-clearlogs.sh" do
  source "smm-clearlogs.sh"
  owner 'root'
  group 'root'
  mode 0755
end

cron "smm-clearlogs" do
  hour "5"
  minute "0"
  command "/root/bin/smm-clearlogs.sh"
end

#
