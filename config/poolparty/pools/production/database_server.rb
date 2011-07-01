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
  # ebs_volumes do
  #   size 40
  #   device "/dev/sdh"
  #   snapshot_id "snap-e9e9d581" #TODO find a way to automate this as it's new everyday...!
  # end
  
  chef :solo do
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")
    
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
                  :bind_address    => ''
                }
      )
          
  end
  
  security_group "database" do
    authorize :from_port => "22", :to_port => "22"
  end
  
  security_group "sphinx"
end
