SETTINGS = File.open( File.join(File.dirname(__FILE__), '..', 'settings.yml') ) { |yf| YAML::load( yf ) }[Rails.env]

::AppConfig = ApplicationConfiguration.new("#{Rails.root}/config/app_config.yml",
                                           "#{Rails.root}/config/app_config/#{Rails.env}.yml")
