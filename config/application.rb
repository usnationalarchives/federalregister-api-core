require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FederalregisterApiCore
  class Application < Rails::Application
    # These config hooks used to live in environment.rb in the Rails 2 app.
    #=============================================================================

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W(./lib )
    config.eager_load_paths += %W(./lib)

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

    config.cache_store = :file_store, "#{RAILS_ROOT}/tmp/cache"

    config.rails_lts_options = { :disable_xml_parsing => true }
    #=============================================================================

    config.load_defaults "6.0"
    Rails.autoloaders.main.ignore(Rails.root.join('app/indices'))
    Rails.autoloaders.main.ignore(Rails.root.join('lib/base_extensions'))

    # Enable verbose zeitwerk logging
    # Rails.autoloaders.log!

    Rails.application.config.active_record.belongs_to_required_by_default = false

    config.session_store :cookie_store, **{
      :cookie_only => true,
      :path        => '/admin',
      :secure      => (Rails.env.production? || Rails.env.staging?)
    }



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

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_dispatch.ip_spoofing_check = false

    config.active_support.deprecation = :log
  end
end
