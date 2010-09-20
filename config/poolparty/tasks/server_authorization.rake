namespace :fr2 do
  namespace :authorize do
    require 'yaml'

    
    @amazon_keys = File.open( File.join(File.dirname(__FILE__), '..', '..', 'amazon.yml') ) { |yf| YAML::load( yf ) }
    
    task :staging do
      staging_groups = [
                          ['database_staging', 'app_staging'   ],
                          ['database_staging', 'worker_staging'],
                          ['sphinx_staging',   'worker_staging'],
                          ['app_staging',      'proxy_staging' ],
                          ['static_staging',   'proxy_staging' ],
                          # need to be able to clear varnish cache
                          ['proxy_staging',    'worker_staging'],
                          ['proxy_staging',    'app_staging']
                       ]
      staging_groups.each do |auth_group|
        put "ec2-authorize #{auth_group[0]} -o #{auth_group[1]} -u #{@amazon_keys['aws_account_id']}"
      end
    end
  end
end