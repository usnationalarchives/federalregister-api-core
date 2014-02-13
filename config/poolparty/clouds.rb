require 'yaml'
require 'lib/base_extensions/hash_extensions.rb'

def get_keys
  @amazon_keys     = File.open( File.join(File.dirname(__FILE__), '..', 'amazon.yml') ) { |yf| YAML::load( yf ) }
  @mysql_passwords = File.open( File.join(File.dirname(__FILE__), '..', 'mysql.yml' ) ) { |yf| YAML::load( yf ) }
  @wordpress_keys = File.open( File.join(File.dirname(__FILE__), '..', '..', '..', 'fr2_blog', 'config', 'wordpress_keys.yml') ) { |yf| YAML::load( yf ) }
  @sendgrid_keys  = File.open( File.join(File.dirname(__FILE__), '..', 'sendgrid.yml') ) { |yf| YAML::load( yf ) }
  @splunk_keys    = File.open( File.join(File.dirname(__FILE__), '..', 'splunk.yml') ) { |yf| YAML::load( yf ) }
  @secrets        = File.open( File.join(File.dirname(__FILE__), '..', 'secrets.yml' ) ) { |yf| YAML::load( yf ) }
end

def munin_host(ip_addresses)
  result = []
  ip_addresses.each do |ip|
    result << {:hostname => "ip-#{ip.gsub('.', '-')}" , :ipaddress => ip }
  end
  return result
end

def chef_cloud_attributes(instance_type)
  get_keys
  
  #users
  @deploy_credentials = File.open( File.join(File.dirname(__FILE__), '..', 'deploy_credentials.yml') ) { |yf| YAML::load( yf ) }

  @app = {}
  @app[:name] = 'fr2'


  @app_server_port    = "8080"
  @static_server_port = "8080"
  @my_fr2_server_port = "8081"
  @audit_server_port  = "8080"
  @blog_proxy_port    = "80"
  @resque_server_port = "80"
  @iodocs_server_port = "5768"
  @app_url  = case instance_type
              when 'staging'
                'fr2.criticaljuncture.org'
              when 'production'
                'federalregister.gov'
              end


  case instance_type
  when 'staging'
    @proxy_server_address    = '10.244.142.152'
    @static_server_address   = '10.85.5.241'
    @worker_server_address   = '10.85.5.241'
    @blog_server_address     = '10.85.5.241'
    @mail_server_address     = '10.85.5.241'
    @splunk_server_address   = '10.85.5.241'
    @redis_server_address    = '10.85.5.241'
    @iodocs_server_address   = '10.85.5.241'
    @sphinx_server_address   = '10.85.5.241'
    @database_server_address = '10.101.57.196'
    @mongodb_server_address  = '10.101.57.196'
    @app_server_address      = ['10.82.225.119']
    @my_fr2_server_address   = ['10.82.225.119']
  when 'production'
    @proxy_server_address    = '10.39.115.107'
    @static_server_address   = '10.98.146.140'
    @worker_server_address   = '10.98.146.140'
    @blog_server_address     = '10.98.146.140'
    @mail_server_address     = '10.98.146.140'
    @splunk_server_address   = '10.98.146.140'
    @redis_server_address    = '10.98.146.140'
    @iodocs_server_address   = '10.98.146.140'
    @sphinx_server_address   = '10.98.146.140'
    @database_server_address = '10.116.81.89'
    @mongodb_server_address  = '10.116.81.89'
    @app_server_address      = ['10.40.221.230', '10.116.162.47', '10.10.39.7', '10.34.50.43', '10.116.65.97' ]
    @my_fr2_server_address   = ['10.40.221.230', '10.116.162.47', '10.10.39.7', '10.34.50.43', '10.116.65.97']
  end    
  
  @rails_versions = ['2.3.11', '3.1.3']

  case instance_type
  when 'staging'
    @ssl_cert_name      = 'fr2_staging.crt'
    @ssl_cert_key_name  = 'fr2_staging.key'
    @rails_env = 'staging'
    @database_volume_id = 'vol-dae127b7'
    @worker_volume_id   = 'vol-30af8159'
  when 'production'
    @ssl_cert_name      = 'www_federalregister_gov.crt'
    @ssl_cert_key_name  = 'www_federalregister_gov.key'
    @rails_env = 'production'
    @database_volume_id = 'vol-8e12e2e3'
    @worker_volume_id   = 'vol-3acd3d57'
  end

  @resque_web_password = @secrets['resque_web_password']
  
  return {
    :platform => "ubuntu",
    :bootstrap => {:chef => {:client_version => '0.9.14'}},
    :chef    => {
                  :roles => []
                },
    :lsb    => {
                    :code_name  => 'oneiric',
                    # do not put a, b, c, etc in the line below...
                    :ec2_region => 'us-east-1'
               },
    :app => { 
             :blog => {
                  :root  => '/var/www/apps/fr2_blog',
                  :repo_url => 'git@github.com:criticaljuncture/fr2_blog.git'
             },
             :app_root   => '/var/www/apps/fr2',
             :repo_url   => 'git@github.com:criticaljuncture/fr2.git',
             :my_fr => {
                  :root => '/var/www/apps/my_fr2',
                  :repo_url => 'git@github.com:criticaljuncture/my_fr2.git'
             },
             :web_dir    => '/var/www',
             :name       => 'fr2',
             :url        => @app_url
           },
    :apache => {
                  :listen_ports   => [@app_server_port],
                  :vhost_port     => @app_server_port,
                  :my_fr2_port    => @my_fr2_server_port,
                  :server_name    => @app_url,
                  :vhosts         => [
                                        { :server_name    =>  @app_url,
                                          :server_aliases => '',
                                          :port           => @app_server_port,
                                          :docroot        => "/var/www/apps/#{@app[:name]}/current/public",
                                          :name           => @app[:name],
                                          :rewrite_conditions => ""
                                        },
                                        { :server_name    =>  "audit.#{@app_url}",
                                          :server_aliases => '',
                                          :port           => @audit_server_port,
                                          :docroot        => "/var/www/apps/fr2_audit/public",
                                          :name           => 'fr2_audit',
                                          :rewrite_conditions => "" 
                                        },
                                        { :server_name    =>  "resque.#{@app_url}",
                                          :server_aliases => '',
                                          :port           => @resque_server_port,
                                          :docroot        => "/var/www/apps/resque_web/public",
                                          :name           => 'resque-web',
                                          :rewrite_conditions => "" 
                                        },
                                        { :server_name    =>  @app_url,
                                          :server_aliases => '',
                                          :port           => @my_fr2_server_port,
                                          :docroot        => "/var/www/apps/my_fr2/public",
                                          :name           => 'my_fr2',
                                          :rewrite_conditions => "" 
                                        }
                                     ],
                  :web_dir        => '/var/www',
                  :docroot        => '/var/www/apps/fr2/current/public',
                  :name           => 'fr2',
                  :enable_mods    => ["rewrite", "deflate", "expires"]
               },
    :ec2    => true,
    :aws    => {
                :ebs => {
                          :database => {
                                          :volume_id   => @databse_volume_id,
                                          :mount_point => '/vol',
                                          :device      => '/dev/xvdh'
                                       },
                          :worker   => {
                                          :volume_id   => @worker_volume_id,
                                          :mount_point => '/vol',
                                          :device      => '/dev/xvdh'
                                       }
                        },
                :accesskey => @amazon_keys['access_key_id'],
                :secretkey => @amazon_keys['secret_access_key']
               },
    :mysql  => {
                :server_address         => @database_server_address,
                :database_name          => 'fr2_production',
                :my_fr_database_name    => "my_fr2_#{@rails_env}",
                :server_root_password   => @mysql_passwords['server_root_password'],
                :server_repl_password   => @mysql_passwords['server_repl_password'],
                :server_debian_password => @mysql_passwords['server_debian_password'],
                :ec2_path               => "/vol/lib/mysql",
                :ebs_vol_dev            => "/dev/sdh",
                :ebs_vol_size           => 80,
                :tmpdir                 => '/mnt/tmp/mysql',
                :tunable => {
                              :query_cache_size        => '40M',
                              :tmp_table_size          => '100M',
                              :max_heap_table_size     => '100M',
                              :innodb_buffer_pool_size => '4GB'
                            },
                :install_innodb_plugin => true,
                :database_server_fqdn  => 'database.fr2.ec2.internal'
               },
    :rails  => {
                :versions    => @rails_versions,
                :environment => @rails_env,
                :using_thinking_sphinx => 'true',
                :using_mongoid => 'true'
               },
    :capistrano => {
                    :deploy_user => 'deploy'
                   },
    :nginx      => {
                    :varnish_proxy      => true,
                    :varnish_proxy_host => '127.0.0.1',
                    :host_name          => @app_url,
                    :ssl_cert_name      => @ssl_cert_name,
                    :ssl_cert_key_name  => @ssl_cert_key_name
                   },
    :varnish    => {
                    :version           => '2.1.5',
                    :listen_address    => '127.0.0.1',
                    #:app_proxy_host    => @app_server_address,
                    :app_proxy_servers => @app_server_address.each_with_index.map{|ip, index| {:ip => ip, :fqdn => "app-server-#{index + 1}.fr2.ec2.internal", :alias => "app_server_#{index + 1}"} },
                    :app_proxy_port    => @app_server_port,
                    :static_proxy_host => 'static.fr2.ec2.internal',
                    :static_proxy_port => @static_server_port,
                    :proxy_host_name   => @app_url,
                    :audit_proxy_host_name => "audit.#{@app_url}",
                    :skip_cache_key    => @secrets['varnish']['skip_cache_key'],
                    #:my_fr2_proxy_host => @my_fr2_server_address,
                    :my_fr2_proxy_servers => @my_fr2_server_address.each_with_index.map{|ip, index| {:ip => ip, :fqdn => "my-fr2-server-#{index + 1}.fr2.ec2.internal", :alias => "my_fr2_server_#{index + 1}"} },
                    :my_fr2_proxy_port => @my_fr2_server_port,
                    :iodocs_proxy_host => 'iodocs.fr2.ec2.internal',
                    :iodocs_proxy_port => @iodocs_server_port
                   },
    :ubuntu     => {
                    :users => {
                      :deploy => {
                                  :private_key => @deploy_credentials['private_key'],
                                  :authorized_keys => @deploy_credentials['authorized_keys']
                                 }
                    },
                    :aws_config_path => 'config.internal.federalregister.gov',
                    :servers => [
                                  {:ip => @proxy_server_address,    :fqdn => 'proxy.fr2.ec2.internal',    :alias => 'proxy'},
                                  {:ip => @static_server_address,   :fqdn => 'static.fr2.ec2.internal',   :alias => 'static'},
                                  {:ip => @worker_server_address,   :fqdn => 'worker.fr2.ec2.internal',   :alias => 'worker'},
                                  {:ip => @blog_server_address,     :fqdn => 'blog.fr2.ec2.internal',     :alias => 'blog'},
                                  {:ip => @database_server_address, :fqdn => 'database.fr2.ec2.internal', :alias => 'database'},
                                  {:ip => @sphinx_server_address,   :fqdn => 'sphinx.fr2.ec2.internal',   :alias => 'sphinx'},
                                  {:ip => @mail_server_address,     :fqdn => 'mail.fr2.ec2.internal',     :alias => 'mail'},
                                  {:ip => @splunk_server_address,   :fqdn => 'splunk.fr2.ec2.internal',   :alias => 'splunk'},
                                  {:ip => @mongodb_server_address,  :fqdn => 'mongodb.fr2.ec2.internal',  :alias => 'mongodb'},
                                  {:ip => @redis_server_address,    :fqdn => 'redis.fr2.ec2.internal',    :alias => 'redis'},
                                  {:ip => @iodocs_server_address,   :fqdn => 'iodocs.fr2.ec2.internal',   :alias => 'iodocs'}
                                ],
                    :app_servers    => @app_server_address.each_with_index.map{|ip, index| {:ip => ip, :fqdn => "app-server-#{index + 1}.fr2.ec2.internal", :alias => "app-server-#{index + 1}"} },
                    :my_fr2_servers => @my_fr2_server_address.each_with_index.map{|ip, index| {:ip => ip, :fqdn => "my-fr2-server-#{index + 1}.fr2.ec2.internal", :alias => "my-fr2-server-#{index + 1}"} },
                    :proxy_server  => {:ip => @proxy_server_address},
                    :static_server => {:ip => @static_server_address},
                    :worker_server => {:ip => @worker_server_address},
                    :blog_server   => {:ip => @blog_server_address},
                    :database      => {:ip => @database_server_address},
                    :sphinx        => {:ip => @sphinx_server_address},
                    :mail          => {:ip => @mail_server_address},
                    :splunk        => {:ip => @splunk_server_address},
                    :mongodb       => {:ip => @mongodb_server_address},
                    :redis         => {:ip => @redis_server_address},
                    :iodocs        => {:ip => @iodocs_server_address}
                   },
    # :munin      => {
    #                 :nodes => munin_host(@app_server_address),
    #                 :servers => munin_host(@proxy_server_address)
    #                },
    :wordpress => { 
                  :keys              => @wordpress_keys,
                  :database_name     => 'fr2_wordpress',
                  :database_user     => 'wordpress',
                  :database_password => @mysql_passwords['server_wordpress_password'],
                 },
    :postfix => {
                   :smtp_sasl_auth_enable      => 'yes',
                   :smtp_sasl_password_maps    => "static:#{@sendgrid_keys['username']}:#{@sendgrid_keys['password']}",
                   :smtp_sasl_security_options => 'noanonymous',
                   :smtp_tls_security_level    => 'may',
                   :header_size_limit          => 4096000,
                   :mail_type                  => "relay",
                   :relayhost                  => "[smtp.sendgrid.net]:587",
                   :mail_relay_networks        => "127.0.0.0/8 #{@app_server_address.to_a.join(' ')} #{@worker_server_address}",
                   :inet_interfaces            => 'all',
                   :other_domains              => "$mydomain"
                 },
    :mongodb => {
                   :bind_address => 'mongodb.fr2.ec2.internal',
                   :data_dir => '/var/lib/mongodb',
                   :username => '', #'fr2_audit',
                   :password => '', #@secrets['mongodb_fr2_audit_password'],
                   :database => 'fr2_audit',
                   #:auth     => 'true',
                   :ec2_path => '/vol/lib/mongodb'
                 },
    :splunk => { :reciever => {
                    :host => 'splunk.fr2.ec2.internal',
                    :username => @splunk_keys['username'],
                    :password => @splunk_keys['password']
                  }
               },
    :iodocs => { 
                 :repo_url => "git://github.com/criticaljuncture/iodocs.git",
                 :address => "iodocs.fr2.ec2.internal",
                 :port => @iodocs_server_port,
                 :redis_database => 1
               }

  }
end

#require 'config/poolparty/pools/production.rb'
require 'config/poolparty/pools/staging.rb'

