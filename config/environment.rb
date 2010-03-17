# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem "nokogiri", :version => '1.3.2'
  config.gem "chronic", :version => '0.2.3'
  config.gem "zilkey-active_api", :lib => 'active_api', :version => '0.2.0'
  config.gem "curb", :version => '0.4.4.0'
  config.gem "haml", :version => '2.2.14'
  config.gem "chriseppstein-compass", :lib => 'compass', :version => '0.8.8'
  config.gem "geokit", :lib => 'geokit', :version => '1.4.1'
  config.gem 'mislav-will_paginate', :version => '2.3.11', :lib => 'will_paginate'
  config.gem "fastercsv", :version => '1.4.0'
  config.gem "amatch", :version => '0.2.3'
  config.gem "rubyzip", :lib => 'zip/zip', :version => '0.9.1'
  
  config.gem "patron", :version => "0.4.2"
  # sunlight gem and dependencies
  config.gem "json", :version => '1.1.7'
  config.gem "ym4r", :version => '0.6.1'
  config.gem 'sunlight', :version => '1.0.1'
  config.gem 'thinking-sphinx', :version => '1.3.14', :lib => 'thinking_sphinx'
  config.gem 'hoptoad_notifier', :version => '2.1.3'
  config.gem "aws-s3", :lib => "aws/s3", :version => '0.6.2'
  config.gem 'paperclip', :version => '2.3.1.1'
  # disabled as requires C library to install...the Locator module will return a fake result if not installed
  # config.gem "geoip_city", :version => '0.2.0'
  
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"
  
end
