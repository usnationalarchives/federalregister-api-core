SECRETS = File.open( File.join(File.dirname(__FILE__), '..', 'secrets.yml') ) { |yf| YAML::load( yf ) }
