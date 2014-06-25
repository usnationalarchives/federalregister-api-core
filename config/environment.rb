# Use deployed git commit hash as quick & easy cache busting strategy
ENV["RAILS_ASSET_ID"] = `git log -n 1 --pretty=format:%H`

if (File.basename($0) == 'rake' && (ARGV.include?('db:migrate')|| ARGV.include?('db:setup')))
  ENV["ASSUME_UNITIALIZED_DB"] = '1'
end

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.18' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.autoload_paths += %W( app/concerns app/observers app/presenters app/searches app/workers )
  
  # Gems go in RAILS_ROOT/Gemfile
  
  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running, expect during db:migrate and db:setup...
  unless ENV['ASSUME_UNITIALIZED_DB']
    config.active_record.observers = [:agency_observer, :agency_name_observer, :canned_search_observer, :issue_approval_observer, :entry_observer, :public_inspection_document_observer, :public_inspection_issue_observer]
  end

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Eastern Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
  
  config.action_controller.session = {
    :cookie_only => true,
    :path => '/admin',
  }
  config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

  config.rails_lts_options = { :disable_xml_parsing => true }
end
