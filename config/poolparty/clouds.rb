require 'yaml'
require 'lib/base_extensions/hash_extensions.rb'

def get_keys
  @amazon_keys     = File.open( File.join(File.dirname(__FILE__), '..', 'amazon.yml') ) { |yf| YAML::load( yf ) }
  @mysql_passwords = File.open( File.join(File.dirname(__FILE__), '..', 'mysql.yml' ) ) { |yf| YAML::load( yf ) }
end

def munin_host(ip_addresses)
  result = []
  ip_addresses.each do |ip|
    result << {:hostname => "ip-#{ip.gsub('.', '-')}" , :ipaddress => ip }
  end
  return result
end

def chef_cloud_attributes(instance_type)
  get_keys
  
  #users
  @deploy_credentials = File.open( File.join(File.dirname(__FILE__), '..', 'deploy_credentials.yml') ) { |yf| YAML::load( yf ) }
  
  @app_server_port    = "8080"
  @static_server_port = '8080'
  @app_url  = case instance_type
              when 'staging'
                'fr2.criticaljuncture.org'
              when 'production'
                'www.federalregister.gov'
              end

  case instance_type
  when 'staging'
    @proxy_server_address    = '127.0.0.1'
    @static_server_address   = '127.0.0.1'
    @worker_server_address   = '127.0.0.1'
    @database_server_address = '127.0.0.1'
    @sphinx_server_address   = '127.0.0.1'
    @app_server_address      = '127.0.0.1'
  when 'production'
    @proxy_server_address    = '10.194.207.96'  #'ip-10-194-207-96.ec2.internal'
    @static_server_address   = '10.245.106.31'  #'ip-10-245-106-31.ec2.internal'
    @worker_server_address   = '10.245.106.31'  #'ip-10-245-106-31.ec2.internal'
    @database_server_address = '10.194.109.139' #'ip-10-194-109-139.ec2.internal'
    @sphinx_server_address   = '10.194.109.139' #'ip-10-194-109-139.ec2.internal'
    @app_server_address      = ['10.243.41.203', '10.196.117.123', '10.202.162.96', '10.212.73.172', '10.251.83.111', '10.251.131.239', '10.251.49.171', '10.251.234.128']  #'ip-10-243-41-203.ec2.internal'
  end    
              
  return {
    :platform => "ubuntu",
    :bootstrap => {:chef => {:client_version => '0.8.16'}},
    :chef    => {
                  :roles => []
                },
    :lsb    => {
                    :code_name  => 'karmic',
                    :ec2_region => 'us-east-1'
               },
    :apache => {
                  :listen_ports   => [@app_server_port],
                  :vhost_port     => @app_server_port, 
                  :server_name    => @app_url,
                  #:server_aliases => 'www.something',
                  :web_dir        => '/var/www',
                  :docroot        => '/var/www/apps/fr2/current/public',
                  :name           => 'fr2',
                  :enable_mods    => ["rewrite", "deflate", "expires"]
               },
    :ec2    => true,
    :aws    => {
                :ebs => {
                          :volume_id => '',
                          :elastic_ip => ''
                        },
                :accesskey => @amazon_keys['access_key_id'],
                :secretkey => @amazon_keys['secret_access_key']
               },
    :mysql  => {
                :server_address         => @database_server_address,
                :database_name          => 'fr2_production',
                :server_root_password   => @mysql_passwords['server_root_password'],
                :server_repl_password   => @mysql_passwords['server_repl_password'],
                :server_debian_password => @mysql_passwords['server_debian_password'],
                :ec2_path               => "/vol/lib/mysql",
                :ebs_vol_dev            => "/dev/sdh",
                :ebs_vol_size           => 80,
                :tunable => {
                              :query_cache_size => '40M'
                            }
               },
    :rails  => {
                :version     => "2.3.5",
                :environment => "production"
               },
    :capistrano => {
                    :deploy_user => 'deploy'
                   },
    :nginx      => {
                    :varnish_proxy      => true,
                    :varnish_proxy_host => '127.0.0.1',
                    :host_name          => @app_url
                   },
    :varnish    => {
                    :version           => '2.1.2',
                    :listen_address    => '127.0.0.1',
                    :app_proxy_host    => @app_server_address,
                    :app_proxy_port    => @app_server_port,
                    :static_proxy_host => 'static.fr2.ec2.internal',
                    :static_proxy_port => @static_server_port,
                    :proxy_host_name   => @app_url
                   },
    :ubuntu     => {
                    :users => {
                      :deploy => {
                                  :private_key => @deploy_credentials['private_key'],
                                  :authorized_keys => @deploy_credentials['authorized_keys']
                                 }
                    },
                    :proxy_server  => {:ip => @proxy_server_address},
                    :static_server => {:ip => @static_server_address},
                    :worker_server => {:ip => @worker_server_address},
                    :database      => {:ip => @database_server_address},
                    :sphinx        => {:ip => @sphinx_server_address}
                   },
    :munin      => {
                    :nodes => munin_host(@app_server_address),
                    :servers => munin_host(@proxy_server_address)
                   }
  }
end

pool :fr2 do
  
  # cloud :app_server do
  #   # basic settings
  #   using :ec2
  #   keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
  #   user "ubuntu"
  #   #image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
  #   image_id "ami-6ed43c07" #Staging complete stack - Varnish, Apache/Passenger, Rails, MySQL, Sphinx
  #   availability_zones ['us-east-1b']
  #   instances 1
  #   instance_type 'm1.small'
  #   
  #   # attach the ebs volumes
  #   ebs_volumes do
  #     size 40
  #     device "/dev/sdh"
  #     snapshot_id "snap-1c7f3874" #TODO find a way to automate this as it's new everyday...!
  #   end
  #   
  #   chef :solo do
  #     repo File.join(File.dirname(__FILE__) , "chef_cloud")
  #     
  #     recipe "apt"
  #     recipe "ubuntu"
  #     recipe "ec2"
  #     recipe "openssl"
  #     recipe "imagemagick"
  #     
  #     recipe "apache2"
  #     recipe "passenger_enterprise::apache2"
  #     
  #     recipe 'rubygems'
  #     
  #     recipe "mysql::server"
  #     recipe "mysql::server_ec2"
  #     recipe "sphinx"
  #     
  #     recipe "git"
  #     recipe "capistrano"
  #     recipe "rails"
  #     
  #     recipe "apparmor"
  #     
  #     attributes chef_cloud_attributes.recursive_merge(
  #       :passenger_enterprise => {
  #                                   :pool_idle_time => 24*60*60
  #                                }
  #       )
  #                            
  #   end
  #   
  #   security_group "web" do
  #     authorize :from_port => "22", :to_port => "22"
  #     authorize :from_port => "80", :to_port => "80"
  #   end
  #   
  # end
  
  # cloud :staging_server do
  #   # basic settings
  #   using :ec2
  #   keypair "/Users/rburbach/Documents/AWS/govpulse-production1.pem"
  #   user "ubuntu"
  #   #image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
  #   image_id "ami-6ed43c07" #Staging complete stack - Varnish, Apache/Passenger, Rails, MySQL, Sphinx
  #   availability_zones ['us-east-1b']
  #   instances 1
  #   instance_type 'm1.small'
  #   
  #   elastic_ip ['184.73.190.17']
  #   
  #   # attach the ebs volumes
  #   ebs_volumes do
  #     size 40
  #     device "/dev/sdh"
  #     snapshot_id "snap-2bd5f343" #TODO find a way to automate this as it's new everyday...!
  #   end
  #   
  #   chef :solo do
  #     repo File.join(File.dirname(__FILE__) , "chef_cloud")
  #     
  #     recipe "apt"
  #     recipe "ubuntu"
  #     recipe "ec2"
  #     recipe "openssl"
  #     recipe "imagemagick"
  #     
  #     recipe "nginx"
  #     recipe "varnish"
  #     
  #     recipe "apache2"
  #     recipe "passenger_enterprise::apache2"
  #     
  #     recipe 'rubygems'
  #     
  #     recipe "mysql::server"
  #     recipe "mysql::server_ec2"
  #     recipe "sphinx"
  #     
  #     recipe "git"
  #     recipe "capistrano"
  #     recipe "rails"
  #     
  #     recipe "apparmor"
  #     
  #     @elastic_ip = '184.73.190.17'
  #     
  #     attributes chef_cloud_attributes.recursive_merge(
  #       :aws    => {
  #                   :ebs => {
  #                             :volume_id => "vol-708a1819",
  #                             :elastic_ip => @elastic_ip
  #                           }
  #                  },
  #       :varnish => {
  #                     :storage_size => '250M'
  #                   },
  #       :passenger_enterprise => {
  #                                   :pool_idle_time => 24*60*60
  #                                }
  #       )
  #           
  #   end
  #   
  #   security_group "web" do
  #     authorize :from_port => "22", :to_port => "22"
  #     authorize :from_port => "80", :to_port => "80"
  #     authorize :from_port => "8080", :to_port => "8080"
  #   end
  #   
  # end
  
  cloud :staging_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
    #image_id "ami-6ed43c07" #Staging complete stack - Varnish, Apache/Passenger, Rails, MySQL, Sphinx
    availability_zones ['us-east-1d']
    instances 1
    instance_type 'm1.small'
    
    elastic_ip ['184.72.250.132']
    
    #attach the ebs volumes
    ebs_volumes do
      size 80
      device "/dev/sdh"
      snapshot_id "snap-e9e9d581" #TODO find a way to automate this as it's new everyday...!
    end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe "ubuntu"
      recipe "ec2"
      recipe "openssl"
      recipe "imagemagick"
      
      recipe "nginx"
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
      
      @elastic_ip = '184.72.250.132'
      
      attributes chef_cloud_attributes('staging').recursive_merge(
        :aws    => {
                    :ebs => {
                              :volume_id => "vol-d2b52ebb",
                              :elastic_ip => @elastic_ip
                            }
                   },
        :varnish => {
                      :storage_size => '250M'
                    },
        :passenger_enterprise => {
                                    :pool_idle_time => 24*60*60
                                 }
        )
            
    end
    
    security_group "web" do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
      authorize :from_port => "8080", :to_port => "8080"
    end
    
  end
  
  # cloud :test_server do
  #     # basic settings
  #     using :ec2
  #     keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
  #     user "ubuntu"
  #     image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
  #     #image_id "ami-6ed43c07" #Staging complete stack - Varnish, Apache/Passenger, Rails, MySQL, Sphinx
  #     availability_zones ['us-east-1d']
  #     instances 1
  #     instance_type 'm1.small'
  #     
  #     elastic_ip ['184.72.250.132']
  #     
  #     #attach the ebs volumes
  #     ebs_volumes do
  #       size 40
  #       device "/dev/sdh"
  #       snapshot_id "snap-bb143dd3" #TODO find a way to automate this as it's new everyday...!
  #     end
  #     
  #     chef :solo do
  #       repo File.join(File.dirname(__FILE__) , "chef_cloud")
  #       
  #       recipe "apt"
  #       recipe "ubuntu"
  #       recipe "ec2"
  #       recipe "openssl"
  #       recipe "imagemagick"
  #       
  #       recipe "nginx"
  #       recipe "varnish"
  #       
  #       recipe "apache2"
  #       recipe "passenger_enterprise::apache2"
  #       
  #       recipe 'rubygems'
  #       
  #       recipe "mysql::server"
  #       recipe "mysql::server_ec2"
  #       recipe "sphinx"
  #       
  #       recipe "git"
  #       recipe "capistrano"
  #       recipe "rails"
  #       
  #       recipe "apparmor"
  #       
  #       @elastic_ip = '184.72.250.132'
  #       
  #       attributes chef_cloud_attributes('test').recursive_merge(
  #         :aws    => {
  #                     :ebs => {
  #                               :volume_id => "vol-e605998f",
  #                               :elastic_ip => @elastic_ip
  #                             }
  #                    },
  #         :varnish => {
  #                       :storage_size => '250M',
  #                     },
  #         :passenger_enterprise => {
  #                                     :pool_idle_time => 24*60*60
  #                                  }
  #         )
  #             
  #     end
  #     
  #     security_group "web" do
  #       authorize :from_port => "22", :to_port => "22"
  #       authorize :from_port => "80", :to_port => "80"
  #       authorize :from_port => "8080", :to_port => "8080"
  #     end
  #     
  #   end
  
  cloud :proxy_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
    availability_zones ['us-east-1d']
    instances 1
    instance_type 'm1.large'
    
    elastic_ip ['184.72.241.172']
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe 's3sync'
      recipe "ubuntu"
      recipe "openssl"
      
      recipe "munin::server"
      recipe "munin::client"
      
      recipe "nginx"
      recipe "varnish"
      
      attributes chef_cloud_attributes('production').recursive_merge(
        :chef    => {
                      :roles => ['proxy']
                    },
        :varnish => {
                      :storage_size => '3G',
                    },
        :nginx   => {
                      :doc_root      => '/var/www/apps/fr2/current/public'
                    }
        )
            
    end
    
    security_group "proxy" do
      authorize :from_port => "22",   :to_port => "22"
      authorize :from_port => "80",   :to_port => "80"
      authorize :from_port => "443",  :to_port => "443"
      authorize :from_port => "4950", :to_port => "4950"
    end
    
  end
  
  cloud :static_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    image_id "ami-6743ae0e" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 32bit
    availability_zones ['us-east-1d']
    instances 1
    instance_type 'm1.small'
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe 's3sync'
      recipe "ubuntu"
      recipe "openssl"
      
      recipe "munin::client"
      
      recipe "mysql::client"

      recipe "nginx"
      
      recipe 'ruby_enterprise'
      recipe 'rubygems'
      
      recipe "git"
      recipe "capistrano"
      recipe "rails"
      
      attributes chef_cloud_attributes('production').recursive_merge(
        :chef    => {
                      :roles => ['static', 'worker']
                    },
        :nginx   => {
                      :varnish_proxy => false,
                      :gzip          => 'off',
                      :listen_port   => '8080',
                      :doc_root      => '/var/www/apps/fr2/current/public'
                    }
        )
    end
    
    security_group "static" do
      authorize :from_port => "22", :to_port => "22"
      #authorize :from_port => "8080", :to_port => "8080"
    end
    security_group "worker"
    
  end
  
  cloud :app_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    #image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
    image_id "ami-de806bb7" #FR2 Basic App Server
    availability_zones ['us-east-1d']
    instances 8
    instance_type 'm1.large'
    
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe 's3sync'
      recipe "ubuntu"
      recipe "openssl"
      recipe "imagemagick"
      
      recipe "munin::client"
      
      recipe "mysql::client"
      
      recipe "apache2"
      recipe "passenger_enterprise::apache2"
      
      recipe 'rubygems'
      
      recipe "git"
      recipe "capistrano"
      recipe "rails"
      
      attributes chef_cloud_attributes('production').recursive_merge(
        :chef => {
                   :roles => ['app']
                 },
        :passenger_enterprise => {
                                   :pool_idle_time => 100000,
                                   :max_requests   => 10000,
                                   :max_pool_size  => 70
                                 },
        :apache => {
                     :prefork => {
                                  :startservers        => 128,
                                  :minspareservers     => 32,
                                  :maxspareservers     => 128
                                 }
                   }
        )
            
    end
    
    security_group "app" do
      authorize :from_port => "22", :to_port => "22"
      #authorize :from_port => "8080", :to_port => "8080"
    end
    
  end
  
  cloud :database_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
    availability_zones ['us-east-1d']
    instances 1
    instance_type 'm1.large'
    
    #attach the ebs volumes
    ebs_volumes do
      size 40
      device "/dev/sdh"
      snapshot_id "snap-e9e9d581" #TODO find a way to automate this as it's new everyday...!
    end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe 's3sync'
      recipe "ubuntu"
      recipe "openssl"
      
      recipe "munin::client"
      
      recipe "mysql::server"
      recipe "mysql::server_ec2"
      recipe "sphinx"
      
      recipe "apparmor"
      
      attributes chef_cloud_attributes('production').recursive_merge(
        :chef => {
                   :roles => ['database']
                 },
        :aws  => {
                    :ebs => { :volume_id => "vol-8a53cbe3" }
                 },
        :mysql => {
                    :bind_address    => '127.0.0.1'
                  }
        )
            
    end
    
    security_group "database" do
      authorize :from_port => "22", :to_port => "22"
    end
    
    security_group "sphinx"
  end
  
  cloud :static_server_large do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
    user "ubuntu"
    #image_id "ami-6743ae0e" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 32bit
    image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
    availability_zones ['us-east-1d']
    instances 1
    #instance_type 'm1.small'
    instance_type 'c1.xlarge'
    
    #attach the ebs volumes
    # ebs_volumes do
    #   size 80
    #   device "/dev/sdh"
    # end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe 's3sync'
      recipe "ubuntu"
      recipe "openssl"
      recipe "imagemagick"
      
      recipe "munin::client"
      
      recipe "mysql::client"

      recipe "nginx"
      
      recipe 'ruby_enterprise'
      recipe 'rubygems'
      
      recipe "git"
      recipe "capistrano"
      recipe "rails"
      
      attributes chef_cloud_attributes('production').recursive_merge(
        :chef    => {
                      :roles => ['static', 'worker']
                    },
        :nginx   => {
                      :varnish_proxy => false,
                      :gzip          => 'off',
                      :listen_port   => '8080',
                      :doc_root      => '/var/www/apps/fr2/current/public'
                    }
        )
    end
    
    security_group "static" do
      authorize :from_port => "22", :to_port => "22"
      #authorize :from_port => "8080", :to_port => "8080"
    end
    security_group "worker"
    
  end
end
