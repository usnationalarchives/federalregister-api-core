require "active_support/core_ext/integer/time"
APP_HOST_NAME = 'www.fr2.local:8080'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Allow Better Errors to access IP for remote development.  Click "show env dump" on the standard better_errors error page to view IP.
  # BetterErrors::Middleware.allow_ip! 'X.X.X.X'

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    # config.cache_store = :memory_store
    # config.public_file_server.headers = {
    #   'Cache-Control' => "public, max-age=#{2.days.to_i}"
    # }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  smtp_settings = {
    :address        => "smtp.sendgrid.net",
    :port           => "587",
    :domain         => "#{APP_HOST_NAME}",
    :user_name      => Rails.application.credentials.dig(:sendgrid, :username),
    :password       => Rails.application.credentials.dig(:sendgrid, :password),
    :authentication => :plain
  }

  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.smtp_settings   = smtp_settings

  config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}", :protocol => "http://"}

  Rails.application.routes.default_url_options = {:host => "dev-fr2.criticaljuncture.org", :protocol => "https"}

  # Note: Set this in your development.local.yml
  Settings.development_flags.permitted_hosts&.split(',')&.each do |host|
    config.hosts << host
  end
end
