require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FederalregisterApiCore
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

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
    config.time_zone = 'Eastern Time (US & Canada)'
    # config.eager_load_paths << Rails.root.join("extras")

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.action_dispatch.ip_spoofing_check = false

    config.active_support.deprecation = :log
  end
end
