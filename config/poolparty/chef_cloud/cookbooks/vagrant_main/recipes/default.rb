# vagrant_main cookbook
# require all your recipes here!
#

require_recipe "apt"
require_recipe "ubuntu"
#require_recipe "ec2"
require_recipe "openssl"
require_recipe "imagemagick"

require_recipe "apache2"
require_recipe "passenger_enterprise"
require_recipe "passenger_enterprise::apache2"

require_recipe 'rubygems'

require_recipe "mysql::server"
#require_recipe "mysql::server_ec2"
require_recipe "sphinx"

require_recipe "git"
require_recipe "capistrano"
require_recipe "rails"