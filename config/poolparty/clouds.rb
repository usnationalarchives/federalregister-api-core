pool :fr2 do
  
  cloud :app_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/govpulse-production1.pem"
    user "ubuntu"
    image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
    availability_zones ['us-east-1b']
    instances 1
    instance_type 'm1.small'
    
    # attach the ebs volumes
    ebs_volumes do
      size 40
      device "/dev/sdh"
      snapshot_id "snap-5aa8c532" #TODO find a way to automate this as it's new everyday...!
    end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apt"
      recipe "ubuntu"
      recipe "ec2"
      recipe "openssl"
      recipe "imagemagick"
      
      #recipe "mysql"
      #recipe "mysql::client"
      recipe "mysql::server"
      recipe "mysql::server_ec2"
      recipe "sphinx"
      
      recipe "apache2"
      recipe "passenger_enterprise"
      recipe "passenger_enterprise::apache2"
      
      recipe "git"
      recipe "rails"
      recipe "capistrano"
      
      
      attributes  :lsb    => {
                                  :code_name  => 'karmic',
                                  :ec2_region => 'us-east-1'
                             },
                  :apache => {
                                :listen_ports   => ["80"], 
                                :server_name    => 'test.fr2.criticaljuncture.org',
                                #:server_aliases => 'www.something',
                                :web_dir        => '/var/www',
                                :docroot        => '/var/www/apps/fr2/current/public',
                                :name           => 'fr2',
                                :enable_mods    => ["rewrite", "deflate", "expires"]
                             },
                  :ec2    => true,
                  :mysql  => {
                              :server_root_password   => 'abcd1234',
                              :server_repl_password   => '1234abcd',
                              :server_debian_password => '12abcd34',
                              :ec2_path               => "/vol/lib/mysql",
                              :ebs_vol_dev            => "/dev/sdh",
                              :ebs_vol_size           => 40
                             },
                  :rails  => {
                              :version     => "2.3.5",
                              :environment => "production"
                             }
                             
    end
    
    security_group "web" do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
    end
    
  end
end
