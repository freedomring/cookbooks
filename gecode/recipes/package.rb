#
# Author:: Christopher Walters (<cw@opscode.com>)
# Author:: Nuo Yan (<nuo@opscode.com>)
# Author:: Joshua Timberman (<joshua@opscode.com>)
# Author:: Seth Chisamore (<schisamo@opscode.com>)
# Cookbook Name:: gecode
# Recipe:: package
#
# Copyright:: Copyright (c) 2011 Opscode, Inc.
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

case node['platform_family']
when 'debian'

  include_recipe 'apt'

  # use opscode apt repo for older releases
  if (platform?("debian") && (node.platform_version.to_f < 7.0)) ||
      (platform?("ubuntu") && (node.platform_version.to_f < 11.0))

    # add Opscode's apt repo to sources
    apt_repository "opscode" do
      uri "http://apt.opscode.com"
      components ["main"]
      distribution node['lsb']['codename']
      key "2940ABA983EF826A"
      keyserver "pgpkeys.mit.edu"
      action :add
    end

  end

  apt_package 'libgecode-dev' do
    action :upgrade
  end

when 'rhel','fedora'

  if (platform?("redhat") || platform?("centos") || platform?("scientific"))
    if node.platform_version.to_f < 6.0
      raise "This recipe does not yet support installing Gecode 3.5.0+ from packages on your platform"
    else
      include_recipe 'yum::epel'
    end
  elsif (platform?("fedora") && (node.platform_version.to_f < 16.0))
      raise "This recipe does not yet support installing Gecode 3.5.0+ from packages on your platform"
  end

  package 'gecode-devel' do
    action :install
  end

else
  raise "This recipe does not yet support installing Gecode 3.5.0+ from packages on your platform"
end
