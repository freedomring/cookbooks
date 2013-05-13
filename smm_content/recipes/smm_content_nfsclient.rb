#
# Cookbook Name:: smm_content
# Recipe:: smm_content::smm_content_nfsclient
#
# Copyright 2012, SendMe, Inc
#
# All rights reserved - Do Not Redistribute
#
include_recipe "nfs"

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

	mountServerRole = mountInfo["server-role"]
	mountServer = mountInfo["server"]
	mountLocation = mountInfo["mount_location"]
	mountOwner = mountInfo["owner"]
	mountGroup = mountInfo["group"]
	mountMode = mountInfo["mode"]

	if (! mountServerRole.nil?)
		Chef::Log.info("Looking for servers in role #{mountServerRole} and environment #{environment}")
		# We need to find a server in this environment that is serving this particular mount
		searchResults = search(:node, "roles:#{mountServerRole} AND chef_environment:#{environment}")

		Chef::Log.info("Found #{searchResults.size} servers")

		if (!searchResults.nil? and searchResults.size > 0)
			for searchResult in searchResults.each do
				fqdn = searchResult[:fqdn]

				Chef::Log.info("Looking at server #{searchResult.name} -- #{fqdn}")

				if (! fqdn.nil?)
					# Ok, we have an fqdn, we're going to see if it actually can be resolved
					fqdnTest = `host #{fqdn}`

					fqdnTestResult = $?.exitstatus

					if (fqdnTestResult == 0)
						Chef::Log.info("Seems we were able to look up: #{fqdn}")

						mountServer = fqdn

						break
					end
				end
			end

			if (mountServer.nil?)
				# Didn't find one we could look up, so we're going to go by IP of the first result
				Chef::Log.info("No mount server defined.  Trying to use ip address.")
				searchResult = searchResults[0]

				mountServer = searchResult[:ipaddress]
			end
		else
		  Chef::Log.warn("No servers found for role: #{mountServerRole}")
		end
	end

	if (! mountServer.nil?)
		Chef::Log.info("Mount Server Determined: #{mountServer}")
	else
		# Ouch, neither is good, we have to abort
		Chef::Log.fatal("You must specify the mount attribute 'server-role' to a node or role for this recipe to work.")
	end

	# The first thing we probably want to do here is insure that our directory exists
	# and that it has the correct permissions.
	directory mountLocation do
		recursive true
		owner mountOwner
		group mountGroup
		mode mountMode

		action :create
	end

	mount mountLocation do
		device "#{mountServer}:#{mountLocation}"
		fstype "nfs"
		options "rw"

		dump 0
		pass 0

		action [ :mount, :enable ]
	end
end

