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

sendgrid_keys  = File.open( File.join(File.dirname(__FILE__), '..',
'sendgrid.yml') ) { |yf| YAML::load( yf ) }

smtp_settings = {
 :address        => "smtp.sendgrid.net",
 :port           => "587",
 :domain         => "www.fr2.local",
 :user_name      => sendgrid_keys['username'],
 :password       => sendgrid_keys['password'],
 :authentication => :plain
}

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings   = smtp_settings

config.action_mailer.default_url_options = {:host => 'fr2.local:8080'}

# Put gems in Gemfile...