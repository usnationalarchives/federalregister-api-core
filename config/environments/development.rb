APP_HOST_NAME = 'www.fr2.local:8080'

Rails.application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local = true

  # config.action_view.debug_rjs                         = true
  config.action_controller.perform_caching             = false

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

  config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}", :protocol => "http://"}

  Rails.application.routes.default_url_options = {:host => "dev-fr2.criticaljuncture.org", :protocol => "https"}

  # Expands the lines which load the assets
  config.assets.debug = true
end
