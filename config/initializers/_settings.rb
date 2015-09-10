SETTINGS = File.open( File.join(File.dirname(__FILE__), '..', 'settings.yml') ) { |yf| YAML::load( yf ) }[Rails.env]
