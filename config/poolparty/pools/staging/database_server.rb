cloud :database_server_11 do
  # basic settings
  using :ec2
  keypair "~/Documents/AWS/FR2/gpoEC2.pem"
  user "ubuntu"
  #image_id "ami-7d43ae14" #Ubuntu 9.10 Karmic Canonical, ubuntu@ EBS-based 64bit
  # image_id "ami-723dc81b" # Staging database ami
  image_id "ami-1aad5273" #Ubuntu 11.04 Natty Canonical, ubuntu@ EBS-based 64bit
  availability_zones ['us-east-1d']
  instances 1
  instance_type 'm1.large'
  
  #attach the ebs volumes
  # ebs_volumes do
  #   size 80
  #   device "/dev/sdh"
  #   snapshot_id "snap-74d5801f" #TODO find a way to automate this as it's new everyday...!
  # end
  
  chef :solo do
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")
    
    recipe "apt"
    recipe 's3sync'
    recipe "ubuntu"
    recipe "openssl"
    
    recipe "apparmor"

    recipe "munin::client"
    
    recipe "mysql::server"
    recipe "mysql::server_ec2"
    recipe "sphinx"
    recipe "mongodb"

    attributes chef_cloud_attributes('staging').recursive_merge(
      :bootstrap => {:chef => {:client_version => '0.9.12'}},
      :lsb    => {
                    :code_name  => 'natty',
                    :ec2_region => 'us-east-1'
               },
      :chef => {
                 :roles => ['database']
               },
      :aws  => {
                  :ebs => { :volume_id => "vol-fa4c6893" }
               },
      :mysql => {
                  :bind_address    => '',
                  :tunable => {:max_connections => "50"}
                },
      :rails  => { :environment => "staging" },
      #:ubuntu => { :hostname => 'database'},
      :sphinx => { 
                    :version => "2.0.1-beta",
                    :url => "http://sphinxsearch.com/files/sphinx-2.0.1-beta.tar.gz",
                    :tar_file => "/opt/src/sphinx-2.0.1-beta.tar.gz"
                 }
      )
          
  end
  
  security_group "database_staging" do
    authorize :from_port => "22", :to_port => "22"
  end
  
  security_group "sphinx_staging"
end
