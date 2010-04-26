pool :fr2 do
  
  cloud :app_server do
    # basic settings
    using :ec2
    keypair "/Users/rburbach/Documents/AWS/govpulse-production1.pem"
    user "ubuntu"
    image_id "ami-bb709dd2" #Ubuntu 9.10 Karmic Canonical, ubuntu@
    availability_zones ['us-east-1b']
    instances 1
    
    #disable :haproxy
    
    # attach the ebs volumes
    # ebs_volumes do
    #   size 40
    #   device "/dev/sdh"
    #   snapshot_id "snap-24b1654c" #TODO find a way to automate this as it's new everyday...!
    # end
    
    chef :solo do
      repo File.join(File.dirname(__FILE__) , "chef_cloud")
      
      recipe "apache2"
      attributes :apache => {
                                :listen_ports   => ["80"], 
                                :server_name    => 'test.fr2.criticaljuncture.org',
                                #:server_aliases => 'www.something',
                                :docroot        => '/var/www/apps/fr2/current/public',
                                :name           => 'fr2',
                                :enable_mods    => ["rewrite", "deflate", "expires"]
                             }
                             
      attributes :params => {
                              :name => 'fr2',
                            }
                             
    end
    
    security_group "web" do
      authorize :from_port => "22", :to_port => "22"
      authorize :from_port => "80", :to_port => "80"
    end
    
  end
end
