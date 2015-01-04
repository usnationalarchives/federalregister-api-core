cloud :worker_server do
  # basic settings
  using :ec2
  keypair "~/Documents/AWS/FR2/gpoEC2.pem"
  user "ubuntu"
  #image_id "ami-913ad1f8" #Basic Static Server
  image_id "ami-4dad7424" #Ubuntu 11.10 Karmic Canonical, ubuntu@ EBS-based 64bit
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
    repo File.join(File.dirname(__FILE__) ,"..", "..", "..", "..", "vendor", "plugins")

    recipe "apt"
    recipe 's3sync'
    recipe "ubuntu"
    #recipe "openssl"
    #recipe "imagemagick"
    #recipe "postfix"

    #recipe 'princexml'
    #recipe 'monit'

    #recipe "mysql::client"
    recipe "sphinx"

    #recipe "nginx"

    #recipe "apache2"
    #recipe "php::php5"
    #recipe "passenger_enterprise::apache2"

    #recipe 'rubygems'

    #recipe "git"
    #recipe "capistrano"
    #recipe "rails"
    #recipe "redis"
    #recipe "resque_web"

    #recipe "iodocs"

    attributes chef_cloud_attributes('staging').recursive_merge(
      :chef    => {
                    :roles => ['static', 'worker', 'blog', 'my_fr2', 'iodocs']
                  },
      :nginx   => {
                    :varnish_proxy => false,
                    :gzip          => 'off',
                    :listen_port   => '8080',
                    :doc_root      => '/var/www/apps/fr2/public'
                  },
      :aws     => {
                     :ebs => { :volume_id => "vol-3c02cf46" }
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
                 },
      :resque_web => {
                      :password => @resque_web_password
                     },
      :sphinx => {
                    :version => "2.1.1-beta",
                    :url => "http://sphinxsearch.com/files/sphinx-2.1.1-beta.tar.gz",
                    :tar_file => "/opt/src/sphinx-2.1.1-beta.tar.gz"
                 },
      :monit => {
                  :check_interval => 30,
                  :mail_from_address => "monit-#{@rails_env}@federalregister.gov",
                  :alert_to_address => 'info@criticaljuncture.org',
                  :monitors => [{:name => 'resque_worker_fr_index',
                                 :monitor_type => 'resque',
                                 :options => {:queue => 'public_inspection,fr_index_pdf_previewer,fr_index_pdf_publisher',
                                              :queue_count => 4,
                                              :interval => 1,
                                              :app_path => "/var/www/apps/#{@app[:name]}",
                                              :total_mem => "500 MB",
                                              :total_mem_cycles => "10"
                                             }
                                },
                                {:name => 'redis',
                                 :monitor_type => 'redis',
                                 :options => {:host => '127.0.0.1',
                                              :port => 6379,
                                              :total_mem => '200 MB',
                                              :total_mem_cycles => 5,
                                              :max_children => 255,
                                              :max_children_cycles => 5,
                                              :max_cpu_percent => '95%',
                                              :max_cpu_percent_cycles => 5,
                                             }
                                }
                               ]
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
