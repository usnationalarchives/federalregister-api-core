require 'yaml'
require 'lib/base_extensions/hash_extensions.rb'

def get_keys
  @amazon_keys     = File.open( File.join(File.dirname(__FILE__), '..', 'amazon.yml') ) { |yf| YAML::load( yf ) }
  @mysql_passwords = File.open( File.join(File.dirname(__FILE__), '..', 'mysql.yml' ) ) { |yf| YAML::load( yf ) }
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
  
  @app_server_port    = "8080"
  @static_server_port = '8080'
  @app_url  = case instance_type
              when 'staging'
                'fr2.criticaljuncture.org'
              when 'production'
                'federalregister.gov'
              end

  case instance_type
  when 'staging'
    @proxy_server_address    = '10.195.190.36'
    @static_server_address   = '10.196.142.63'
    @worker_server_address   = '10.196.142.63'
    @database_server_address = '10.242.45.235'
    @sphinx_server_address   = '10.242.45.235'
    @app_server_address      = '10.242.46.47'
  when 'production'
    @proxy_server_address    = '10.194.207.96'
    @static_server_address   = '10.245.106.31'
    @worker_server_address   = '10.245.106.31'
    @database_server_address = '10.194.109.139'
    @sphinx_server_address   = '10.194.109.139'
    @app_server_address      = ['10.243.41.203', '10.196.117.123', '10.202.162.96', '10.212.73.172', '10.251.83.111', '10.251.131.239']
  end    
  
  case instance_type
  when 'staging'
    @ssl_cert_name      = 'fr2_staging.crt'
    @ssl_cert_key_name  = 'fr2_staging.key'
  when 'production'
    @ssl_cert_name      = 'fr2_admin.crt'
    @ssl_cert_key_name  = 'fr2_admin.key'
  end
  
  return {
    :platform => "ubuntu",
    :bootstrap => {:chef => {:client_version => '0.8.16'}},
    :chef    => {
                  :roles => []
                },
    :lsb    => {
                    :code_name  => 'karmic',
                    :ec2_region => 'us-east-1'
               },
    :apache => {
                  :listen_ports   => [@app_server_port],
                  :vhost_port     => @app_server_port, 
                  :server_name    => @app_url,
                  #:server_aliases => 'www.something',
                  :web_dir        => '/var/www',
                  :docroot        => '/var/www/apps/fr2/current/public',
                  :name           => 'fr2',
                  :enable_mods    => ["rewrite", "deflate", "expires"]
               },
    :ec2    => true,
    :aws    => {
                :ebs => {
                          :volume_id => '',
                          :elastic_ip => ''
                        },
                :accesskey => @amazon_keys['access_key_id'],
                :secretkey => @amazon_keys['secret_access_key']
               },
    :mysql  => {
                :server_address         => @database_server_address,
                :database_name          => 'fr2_production',
                :server_root_password   => @mysql_passwords['server_root_password'],
                :server_repl_password   => @mysql_passwords['server_repl_password'],
                :server_debian_password => @mysql_passwords['server_debian_password'],
                :ec2_path               => "/vol/lib/mysql",
                :ebs_vol_dev            => "/dev/sdh",
                :ebs_vol_size           => 80,
                :tunable => {
                              :query_cache_size        => '40M',
                              :tmp_table_size          => '100M',
                              :max_heap_table_size     => '100M',
                              :innodb_buffer_pool_size => '4GB'
                            }
               },
    :rails  => {
                :version     => "2.3.8",
                :environment => "production"
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
                    :version           => '2.1.2',
                    :listen_address    => '127.0.0.1',
                    :app_proxy_host    => @app_server_address,
                    :app_proxy_port    => @app_server_port,
                    :static_proxy_host => 'static.fr2.ec2.internal',
                    :static_proxy_port => @static_server_port,
                    :proxy_host_name   => @app_url
                   },
    :ubuntu     => {
                    :users => {
                      :deploy => {
                                  :private_key => @deploy_credentials['private_key'],
                                  :authorized_keys => @deploy_credentials['authorized_keys']
                                 }
                    },
                    :aws_config_path => 'config.internal.federalregister.gov',
                    :proxy_server  => {:ip => @proxy_server_address},
                    :static_server => {:ip => @static_server_address},
                    :worker_server => {:ip => @worker_server_address},
                    :database      => {:ip => @database_server_address},
                    :sphinx        => {:ip => @sphinx_server_address}
                   },
    :munin      => {
                    :nodes => munin_host(@app_server_address),
                    :servers => munin_host(@proxy_server_address)
                   }
  }
end

#require 'config/poolparty/pools/production.rb'
require 'config/poolparty/pools/staging.rb'

