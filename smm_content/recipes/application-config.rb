# -- CONFIGURATION VARIABLES

apache_user = ( node["apache"]["apache_user"] rescue "smapache" )
apache_group = ( node["apache"]["apache_group"] rescue "smapache" )
apache_home = ( node["apache"]["apache_home"] rescue "smapache" )

environment = node["environment"]

# Check for an apache user for the current environment
if (apache_home.nil? or apache_user.nil?)
  Chef::Log.fatal("No valid apache user found for #{environment}")
end

# Set the local databag for our current environment
environmentSettings = Chef::DataBagItem.load('smm', "#{environment}") rescue {}
if (environmentSettings.nil?)
  Chef::Log.fatal("No environment settings found for #{environment}")
end

# Set the Application name
applicationName = ( node["smm"]["webapp_name"] rescue "smm-content-web")
Chef::Log.info("Loading application properties for #{applicationName}")

# Get Application Properties
applicationProperties = ( environmentSettings["applications"][applicationName] rescue nil )
if(applicationProperties.nil?)
  Chef::Log.fatal("No application settings found for #{environment}")
end

# Get mail Properties from our environment settings
mailProperties = ( smmProperties["mail"] rescue nil )
if(mailProperties.nil?)
  Chef::Log.fatal("No mail properties found for #{environment}")
end

# -- / CONFIGURATION VARIABLES

directory "/mnt/content" do
  owner apache_user
  group apache_group
  mode "0775"
  action :create
end

template "#{applicationName}-80.conf" do
  path   "/etc/apache2/sites-available/#{applicationName}-80.conf"
  source "web_app.conf.erb"
  owner root and group root and mode 0755
  variables(
      :mailProperties => mailProperties
  )
  notifies :restart, "service[apache]", :delayed
end