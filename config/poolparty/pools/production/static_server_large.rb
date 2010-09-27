cloud :static_server_large do
  # basic settings
  using :ec2
  keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
  user "ubuntu"
  image_id "ami-7d43ae14" #Basic Static Server
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