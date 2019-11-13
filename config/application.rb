require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module FR2
  class Application < Rails::Application

  # These config hooks used to live in environment.rb in the Rails 2 app.
  #=============================================================================

  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  config.autoload_paths += %W( ./app/concerns ./app/observers ./app/presenters ./app/searches ./app/workers ./lib )

  # Gems go in RAILS_ROOT/Gemfile

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running, expect during db:migrate and db:setup...
  unless ENV['ASSUME_UNITIALIZED_DB']
    config.active_record.observers = [
      :agency_observer,
      :agency_name_observer,
      :canned_search_observer,
      :entry_observer,
      :fr_index_agency_status_observer,
      :issue_approval_observer
    ]
  end

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'Eastern Time (US & Canada)'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # TODO: B.C. Investigate alternative

  # config.action_controller.session = {
  #   # :key => '_myapp_session',
  #   # :secret => 'Abcd1234',
  #   :cookie_only => true,
  #   :path => '/admin',
  # }

  config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

  config.rails_lts_options = { :disable_xml_parsing => true }

  # use our binary logger as the application logger
  # config.logger = ActiveSupport::BinaryBufferedLogger.new( File.join(RAILS_ROOT, "log", "#{RAILS_ENV}.log") )
  #=============================================================================

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_dispatch.ip_spoofing_check = false

    config.filter_parameters << :password
    config.filter_parameters << :password_confirmation
  end
end
