cloud :app_server_v2 do
  # basic settings
  using :ec2
  keypair "gpoEC2.pem"
  user "ubuntu"
  #image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
  #image_id "ami-de806bb7" #FR2 Basic App Server
  #image_id "ami-4dad7424" #Ubuntu 11.10 Oneiric, EBS-based 64bit
  image_id "ami-aa17b2c2" #Ubuntu 12.04 LTS Trusty EBS-SSD boot 64bi
  #image_id "ami-18389d70" #Ubuntu 14.04 LTS Trusty EBS-SSD boot 64bit
  availability_zones ['us-east-1d']
  instances 1
  instance_type 'm1.large'


  chef :solo do
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")

    recipe "apt"
    recipe 's3sync'
    recipe "ubuntu"

    recipe "openssl"
    recipe "imagemagick"

    recipe "mysql::client"

    recipe "apache2"
    recipe "passenger_enterprise::apache2"

    recipe 'rubygems'

    recipe "git"
    recipe "rails"
    recipe "capistrano"
    recipe "nodejs"

    attributes chef_cloud_attributes('staging').recursive_merge(
      :chef => {
                 :roles => ['app']
               },
      :passenger_enterprise => {
                                 :pool_idle_time => 120,
                                 :max_requests   => 250,
                                 :max_pool_size  => 60,
                                 :global_cue     => 'on'
                               },
      :apache => {
                   :prefork => {
                                :startservers        => 128,
                                :minspareservers     => 32,
                                :maxspareservers     => 128
                               }
                 },
      :sphinx => {
                   :server_address => 'sphinx.fr2.ec2.internal'
                 }
      )

  end

  security_group "app_staging" do
    authorize :from_port => "22", :to_port => "22"
    #authorize :from_port => "8080", :to_port => "8080"
    #authorize :from_port => "8081", :to_port => "8081"
  end

end
