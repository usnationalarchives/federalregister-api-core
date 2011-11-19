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
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")
    
    recipe "apt"
    recipe 's3sync'
    recipe "ubuntu"
    recipe "openssl"
    
    recipe "nginx"
    recipe "varnish"
    
    attributes chef_cloud_attributes('production').recursive_merge(
      :chef    => {
                    :roles => ['proxy', 'splunk_proxy', 'resque_proxy']
                  },
      #:ubuntu => { :hostname => 'proxy'},
      :varnish => {
                    :storage_size => '3G',
                    :blog_proxy_host => @blog_server_address,
                    :blog_proxy_port => '80'
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
