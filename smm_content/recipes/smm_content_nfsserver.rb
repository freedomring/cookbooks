#
# Cookbook Name:: smm_content
# Recipe:: smm_content::smm_content_nfsserver
#
# Copyright 2012, SendMe, Inc
#
# All rights reserved - Do Not Redistribute

# Include NFS recipe
include_recipe "nfs::server"

# Ok, how about some data bags
environment = node.chef_environment

if (environment.nil? or environment == "_default")
	environment = "dev"
end

smmSettings = Chef::DataBagItem.load("smm", environment) rescue {}

if (smmSettings.nil?)
	Chef::Log.fatal("No smm environment settings found for #{environment}")
end

mounts = smmSettings["mounts"]

if (mounts.nil?)
	Chef::Log.fatal("No mount list was found in environment: #{environment}")
end

for mountName in mounts.each_key do
	# Get some vars
	mountInfo = mounts[mountName]

	mountLocation = mountInfo["mount_location"]
	mountOwner = mountInfo["owner"]
	mountGroup = mountInfo["group"]
	mountMode = mountInfo["mode"]

	# The first thing we probably want to do here is insure that our directory exists
	# and that it has the correct permissions.


	directory mountLocation do
		recursive true
		owner mountOwner
		group mountGroup
		mode mountMode

		action :create
	end

	ruby_block "fix-share-ownership-#{mountName}" do
		block do
			ourFile = IO::File.new("#{mountLocation}")

			getEntRegex = /(.*?):(.*?):(.*?):.*/

			userInfo = `getent passwd \"#{mountOwner}\"`
			userInfoResult = $?
			userInfo.strip!

			userId = nil

			if (userInfoResult == 0)
				userId = getEntRegex.match(userInfo)[3]
			else
				Chef::Log.fatal("Could Not Find ID For User: #{mountOwner}")
			end

			groupInfo = `getent group \"#{mountGroup}\"`
			groupInfoResult = $?
			groupInfo.strip!

			groupId = nil

			if (groupInfoResult == 0)
				groupId = getEntRegex.match(groupInfo)[3]
			else
				Chef::Log.fatal("Could Not Find ID For Group: #{mountGroup}")
			end

			ourFile.chown(Integer(userId).to_i, Integer(groupId).to_i)
		end

		action :nothing
	end

	nfs_export mountLocation do
		network "*"
		writeable true
		sync true
		options ["no_subtree_check"]

		notifies :restart, resources(:service => node['nfs']['service']['server']), :delayed
		notifies :create, resources(:ruby_block => "fix-share-ownership-#{mountName}"), :delayed
	end
end
