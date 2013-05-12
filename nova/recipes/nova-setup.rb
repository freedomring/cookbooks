#
# Cookbook Name:: nova
# Recipe:: nova-setup
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Allow for using a well known db password
if node["developer_mode"]
  node.set_unless["nova"]["db"]["password"] = "nova"
else
  node.set_unless["nova"]["db"]["password"] = secure_password
end

include_recipe "nova::nova-common"
include_recipe "mysql::client"
include_recipe "mysql::ruby"

ks_service_endpoint = get_access_endpoint("keystone", "keystone","service-api")
keystone = get_settings_by_role("keystone", "keystone")
keystone_admin_user = keystone["admin_user"]
keystone_admin_password = keystone["users"][keystone_admin_user]["password"]
keystone_admin_tenant = keystone["users"][keystone_admin_user]["default_tenant"]

#creates db and user
#function defined in osops-utils/libraries
create_db_and_user("mysql",
                   node["nova"]["db"]["name"],
                   node["nova"]["db"]["username"],
                   node["nova"]["db"]["password"])

execute "nova-manage db sync" do
  command "nova-manage db sync"
  action :run
  not_if "nova-manage db version && test $(nova-manage db version) -gt 0"
end

node["nova"]["networks"].each do |net|
    execute "nova-manage network create --label=#{net['label']}" do
        # The only two required keys in each network Hash
        # are "label" and "ipv4_cidr".
        cmd = "nova-manage network create --label=#{net['label']} --fixed_range_v4=#{net['ipv4_cidr']}"
        if net.has_key?("multi_host")
            cmd += " --multi_host='#{net['multi_host']}'"
        end
        if net.has_key?("num_networks")
            cmd += " --num_networks=#{net['num_networks']}"
        end
        if net.has_key?("network_size")
            cmd += " --network_size=#{net['network_size']}"
        end
        if net.has_key?("bridge")
            cmd += " --bridge=#{net['bridge']}"
        end
        # Older attributes have the key as "bridge_dev" instead
        # of "bridge_interface"...
        if net.has_key?("bridge_interface") or net.has_key?("bridge_dev")
            val = net.has_key?("bridge_interface") ? net["bridge_interface"] : net["bridge_dev"]
            cmd += " --bridge_interface=#{val}"
        end
        if net.has_key?("dns1")
            cmd += " --dns1=#{net['dns1']}"
        end
        if net.has_key?("dns2")
            cmd += " --dns2=#{net['dns2']}"
        end
        if net.has_key?("vlan")
            cmd += " --vlan=#{net['vlan']}"
        end

        command cmd
        action :run
        not_if "nova-manage network list | grep #{net['ipv4_cidr']}"
    end
end

if node.has_key?(:floating) and node["nova"]["network"]["floating"].has_key?(:ipv4_cidr)
  execute "nova-manage floating create" do
    command "nova-manage floating create --ip_range=#{node["nova"]["network"]["floating"]["ipv4_cidr"]}"
    action :run
    not_if "nova-manage floating list"
  end
end
