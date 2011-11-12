namespace :fr2 do
  namespace :authorize do
    require 'yaml'

    
    @amazon_keys = File.open( File.join(File.dirname(__FILE__), '..', '..', 'config', 'amazon.yml') ) { |yf| YAML::load( yf ) }
    
    AUTH_GROUPS = [
                      ['database', 'app'   ],
                      ['database', 'worker'],
                      ['sphinx',   'worker'],
                      ['app',      'proxy' ],
                      ['app',      'worker'],
                      ['static',   'proxy' ],
                      # need to be able to clear varnish cache
                      ['proxy',    'worker'],
                      ['proxy',    'app']
                   ]
    
    task :staging do
      AUTH_GROUPS.each do |auth_group|
        `ec2-authorize #{auth_group[0]}_staging -o #{auth_group[1]}_staging -u #{@amazon_keys['aws_account_id']}`
      end
    end
    
    task :production do
      AUTH_GROUPS.each do |auth_group|
        `ec2-authorize #{auth_group[0]} -o #{auth_group[1]} -u #{@amazon_keys['aws_account_id']}`
      end
    end
  end
end
