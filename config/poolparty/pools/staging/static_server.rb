cloud :static_server do
  # basic settings
  using :ec2
  keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
  user "ubuntu"
  image_id "ami-913ad1f8" #Basic Static Server
  availability_zones ['us-east-1d']
  instances 1
  instance_type 'm1.large'
  
  #attach the ebs volumes
  # ebs_volumes do
  #   size 80
  #   device "/dev/sdh"
  #   snapshot_id "snap-cea7f0a5" #TODO find a way to automate this as it's new everyday...!
  # end
  
  chef :solo do
    repo File.join(File.dirname(__FILE__) , "chef_cloud")
    
    recipe "apt"
    recipe 's3sync'
    recipe "ubuntu"
    recipe "openssl"
    recipe "imagemagick"
    recipe "postfix"
    
    recipe "munin::client"
    
    recipe "mysql::client"

    recipe "nginx"
    
    recipe "apache2"
    recipe "php::php5"
    recipe "passenger_enterprise::apache2"
    
    recipe 'rubygems'
    
    recipe "git"
    recipe "capistrano"
    recipe "rails"
    
    attributes chef_cloud_attributes('staging').recursive_merge(
      :chef    => {
                    :roles => ['static', 'worker', 'blog']
                  },
      :nginx   => {
                    :varnish_proxy => false,
                    :gzip          => 'off',
                    :listen_port   => '8080',
                    :doc_root      => '/var/www/apps/fr2/current/public'
                  },
      :aws     => {
                     :ebs => { :volume_id => "vol-784f6b11" }
                  },
      :sphinx  => {
                    :server_address => 'sphinx.fr2.ec2.internal'
                  },
      :rails  => { :environment => "staging" },
      :apache => { 
                   :server_aliases => "www.#{@app_url}",
                   :listen_ports   => ['80'],
                   :vhost_port     => '80',
                   :docroot        => '/var/www/apps/fr2_blog/public',
                   :name           => 'fr2_blog',
                   :enable_mods    => ["rewrite", "deflate", "expires"]
                 }
      )
  end
  
  security_group "static_staging" do
    authorize :from_port => "22", :to_port => "22"
    authorize :from_port => "80", :to_port => "80"
    #authorize :from_port => "8080", :to_port => "8080"
  end
  security_group "worker_staging"
  
end