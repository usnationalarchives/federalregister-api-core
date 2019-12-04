APP_HOST_NAME = 'fr2.criticaljuncture.org'

FederalregisterApiCore::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching             = true
  config.action_view.cache_template_loading            = true

  # See everything in the log (default is :info)
  config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "587",
    :domain         => "#{APP_HOST_NAME}",
    :user_name      => Rails.application.secrets['sendgrid']['username'],
    :password       => Rails.application.secrets['sendgrid']['password'],
    :authentication => :plain
  }

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings   = smtp_settings

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  Rails.application.routes.default_url_options = {:host => "fr2.criticaljuncture.org", :protocol => "https"}
  config.action_mailer.default_url_options = {:host => "www.#{APP_HOST_NAME}"}

  # Enable threaded mode
  # config.threadsafe!

  # Commented out in as password protection is really annoying
  # config.action_controller.asset_host = "http://assets%d.fr2.criticaljuncture.org"

  # Expands the lines which load the assets
  config.assets.debug = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = true

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true
end

# Put gems in Gemfile...
ThinkingSphinx.remote_sphinx = true
