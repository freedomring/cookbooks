# default our environment instance variable to Dev if we are currently using default
environment = node.chef_environment
if(environment.nil? or environment == "_default")
  environment = "dev"
end
Chef::Log.info("We seem to be using environment: #{environment}")

default.environment = environment