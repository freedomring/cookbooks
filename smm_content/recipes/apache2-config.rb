# We need to make sure Apache gets installed
include_recipe "apache2"
include_recipe "apache2::mod_ssl"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_deflate"
include_recipe "apache2::mod_headers"

# We also need OpenSSL
package "openssl" do
	action :install
end

# Ok, how about some data bags
environment = node.chef_environment

if (environment.nil? or environment == "_default")
	environment = "dev"
end

smmSettings = Chef::DataBagItem.load("smm", environment) rescue {}

if (smmSettings.nil?)
	Chef::Log.fatal("No smm environment settings found for #{environment}")
end

hostname = node[:hostname]

# Disable the basic sites
apache_site "default" do
	enable false
end

apache_site "default-ssl" do
	enable false
end

applicationName = node[:smm][:webapp_name]

if (! applicationName.nil? )

	applicationSettings = smmSettings["applications"][applicationName]

	if (! applicationSettings.nil?)

		siteFilePath80 = node[:apache][:dir] + "/sites-available/#{applicationName}-80.conf"
		siteFilePath443 = node[:apache][:dir] + "/sites-available/#{applicationName}-443.conf"

		appPath = applicationSettings["context-path"]

		appServerName = applicationSettings["server-name"]

		aliases = applicationSettings["aliases"]

		if (aliases.nil?)
			aliases = Array.new()
		end

		siteEmail = "techops@sendme.com"
		certPassword = "p1ngp0ng"

		confPath = "/etc/ssl/certs/#{appServerName}.conf"
		certPath = "/etc/ssl/certs/#{appServerName}.crt"
		csrPath = "/etc/ssl/certs/#{appServerName}.csr"
		keyPath = "/etc/ssl/certs/#{appServerName}.key"

		directory "/etc/ssl/certs" do
			recursive true
			action :create
		end

		template confPath do
			cookbook "smm_content"
			source "cert.conf.erb"

			variables(
					:key_path => keyPath,
					:site_name => appServerName,
					:site_email => siteEmail,
					:password => certPassword
			)

			not_if { IO::File.exists?(certPath) }
		end

		ruby_block "smm-create-ssl-cert" do
			block do
				Chef::Log.info("Creating fake SSL cert for host: #{hostname}")

				csrCreateTest = system("openssl req -new -config #{confPath} -out #{csrPath}")

				if (! csrCreateTest )
					Chef::Log.fatal("Could not generate CSR")
				end

				convertTest = system("openssl rsa -passin \"pass:#{certPassword}\" -in #{keyPath} -out #{keyPath}")

				if (! convertTest )
					Chef::Log.fatal("Could not strip password from key")
				end

				certTest = system("openssl x509 -req -days 1825 -in #{csrPath} -signkey #{keyPath} -out #{certPath}")

				if (! certTest )
					Chef::Log.fatal("Could not generate certificate")
				end
			end

			not_if { IO::File.exists?(certPath) }
		end

		template siteFilePath443 do
			source "web_app.conf.erb"

			owner "root"

			group node[:apache][:root_group]

			mode 0644

			cookbook "smm_content"

			variables(
					:application_name => applicationName,
					:application_path => appPath,
					:listener => "_default_",
					:port => "443",
					:server_name => appServerName,
					:server_aliases => aliases,
					:docroot => "/mnt/content",
					:cert_path => certPath,
					:key_path => keyPath
			)

			notifies :reload, resources(:service => "apache2"), :delayed

			not_if { IO::File.exists?(siteFilePath443) }
		end

		template siteFilePath80 do
			source "web_app.conf.erb"

			owner "root"

			group node[:apache][:root_group]

			mode 0644

			cookbook "smm_content"

			variables(
					:application_name => applicationName,
					:application_path => appPath,
					:listener => "*",
					:port => "8080",
					:server_name => appServerName,
					:server_aliases => aliases,
					:docroot => "/mnt/content"
			)

			notifies :reload, resources(:service => "apache2"), :delayed

			not_if { IO::File.exists?(siteFilePath80) }
		end

		apache_site "#{applicationName}-80.conf" do
			enable true
		end

		apache_site "#{applicationName}-443.conf" do
			enable true
		end
	else
		Chef::Log.fatal("No settings found for web application: #{applicationName}")
	end
else
	Chef::Log.fatal("A web application name must be specified for this node using attribute [smm][webapp_name]")
end
