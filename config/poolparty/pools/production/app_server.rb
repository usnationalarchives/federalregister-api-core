cloud :app_server do
  # basic settings
  using :ec2
  keypair "/Users/rburbach/Documents/AWS/FR2/gpoEC2.pem"
  user "ubuntu"
  #image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
  image_id "ami-de806bb7" #FR2 Basic App Server
  availability_zones ['us-east-1d']
  instances 5
  instance_type 'm1.large'
  
  
  chef :solo do
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")
    
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
                                 :max_pool_size  => 50
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
