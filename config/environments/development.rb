APP_HOST_NAME = 'fr2.local'

# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

secrets  = File.open(File.join(
  File.dirname(__FILE__), '..', 'secrets.yml'
)) { |yf| YAML::load( yf ) }
sendgrid_keys = secrets['sendgrid']

smtp_settings = {
 :address        => "smtp.sendgrid.net",
 :port           => "587",
 :domain         => "#{APP_HOST_NAME}",
 :user_name      => secrets['sendgrid']['username'],
 :password       => secrets['sendgrid']['password'],
 :authentication => :plain
}

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings   = smtp_settings

config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}:8080"}

# Put gems in Gemfile...
