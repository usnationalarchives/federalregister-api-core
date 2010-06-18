require 'yaml'
require 'lib/base_extensions/hash_extensions.rb'

def get_keys
  @amazon_keys     = File.open( File.join(File.dirname(__FILE__), '..', 'amazon.yml') ) { |yf| YAML::load( yf ) }
  @mysql_passwords = File.open( File.join(File.dirname(__FILE__), '..', 'mysql.yml' ) ) { |yf| YAML::load( yf ) }
end

def chef_cloud_attributes
  get_keys
  @app_server_port = "8080"
  return {
    :platform => "ubuntu",
    :bootstrap => {:chef => {:client_version => '0.8.16'}},
    :lsb    => {
                    :code_name  => 'karmic',
                    :ec2_region => 'us-east-1'
               },
    :apache => {
                  :listen_ports   => [@app_server_port],
                  :vhost_port     => @app_server_port, 
                  :server_name    => 'test.fr2.criticaljuncture.org',
                  #:server_aliases => 'www.something',
                  :web_dir        => '/var/www',
                  :docroot        => '/var/www/apps/fr2/current/public',
                  :name           => 'fr2',
                  :enable_mods    => ["rewrite", "deflate", "expires"]
               },
    :ec2    => true,
    :aws    => {
                :ebs => {
                          :volume_id => "vol-d5fe6ebc"
                        },
                :accesskey => @amazon_keys['access_key_id'],
                :secretkey => @amazon_keys['secret_access_key']
               },
    :mysql  => {
                :server_root_password   => @mysql_passwords['server_root_password'],
                :server_repl_password   => @mysql_passwords['server_repl_password'],
                :server_debian_password => @mysql_passwords['server_debian_password'],
                :ec2_path               => "/vol/lib/mysql",
                :ebs_vol_dev            => "/dev/sdh",
                :ebs_vol_size           => 40
               },
    :rails  => {
                :version     => "2.3.5",
                :environment => "production"
               },
    :capistrano => {
                    :deploy_user => 'deploy'
                   },
    :varnish    => {
                    :version => '2.1.2',
                    :proxy_host => '127.0.0.1',
                    :proxy_port  => @app_server_port
                   }
  }
end

pool :fr2 do
  
  cloud :app_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/govpulse-production1.pem"
    user "ubuntu"
    #image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
    image_id "ami-96c32bff" #FR2 base ami - single server - pre bundler
    availability_zones ['us-east-1b']
    instances 1
    instance_type 'm1.small'
    
    # attach the ebs volumes
    ebs_volumes do
      size 40
      device "/dev/sdh"
      snapshot_id "snap-1c7f3874" #TODO find a way to automate this as it's new everyday...!
    end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe "ubuntu"
      recipe "ec2"
      recipe "openssl"
      recipe "imagemagick"
      
      recipe "apache2"
      recipe "passenger_enterprise::apache2"
      
      recipe 'rubygems'
      
      recipe "mysql::server"
      recipe "mysql::server_ec2"
      recipe "sphinx"
      
      recipe "git"
      recipe "capistrano"
      recipe "rails"
      
      recipe "apparmor"
      
      attributes chef_cloud_attributes.recursive_merge(
        :passenger_enterprise => {
                                    :pool_idle_time => 24*60*60
                                 }
        )
                             
    end
    
    security_group "web" do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
    end
    
  end
  
  cloud :staging_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/govpulse-production1.pem"
    user "ubuntu"
    #image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
    image_id "ami-96c32bff" #FR2 base ami - single server - pre bundler
    availability_zones ['us-east-1b']
    instances 1
    instance_type 'm1.small'
    
    elastic_ip ['184.73.190.17']
    
    # attach the ebs volumes
    ebs_volumes do
      size 40
      device "/dev/sdh"
      snapshot_id "snap-58694d30" #TODO find a way to automate this as it's new everyday...!
    end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe "ubuntu"
      recipe "ec2"
      recipe "openssl"
      recipe "imagemagick"
      
      recipe "varnish"
      
      recipe "apache2"
      recipe "passenger_enterprise::apache2"
      
      recipe 'rubygems'
      
      recipe "mysql::server"
      recipe "mysql::server_ec2"
      recipe "sphinx"
      
      recipe "git"
      recipe "capistrano"
      recipe "rails"
      
      recipe "apparmor"
      
      @elastic_ip = '184.73.190.17'
      
      attributes chef_cloud_attributes.recursive_merge(
        :aws    => {
                    :ebs => {
                              :volume_id => "vol-a346d5ca",
                              :elastic_ip => @elastic_ip
                            }
                   },
        :varnish => {
                      :listen_port     => '80'
                    },
        :passenger_enterprise => {
                                    :pool_idle_time => 24*60*60
                                 }
        )
            
    end
    
    security_group "web" do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
    end
    
  end
end
