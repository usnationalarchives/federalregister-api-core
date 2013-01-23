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

sendgrid_keys  = File.open( File.join(File.dirname(__FILE__), '..',
'sendgrid.yml') ) { |yf| YAML::load( yf ) }

smtp_settings = {
 :address        => "smtp.sendgrid.net",
 :port           => "587",
 :domain         => "#{APP_HOST_NAME}",
 :user_name      => sendgrid_keys['username'],
 :password       => sendgrid_keys['password'],
 :authentication => :plain
}

config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings   = smtp_settings

config.action_mailer.default_url_options = {:host => "#{APP_HOST_NAME}:8080"}

# Put gems in Gemfile...


# configure and initialize MiniProfiler
require 'rack-mini-profiler'
c = ::Rack::MiniProfiler.config
c.pre_authorize_cb = lambda { |env|
  Rails.env.development? || Rails.env.production?
}
tmp = Rails.root.to_s + "/tmp/miniprofiler"
FileUtils.mkdir_p(tmp) unless File.exists?(tmp)
c.storage_options = {:path => tmp}
c.storage = ::Rack::MiniProfiler::FileStore
config.middleware.use(::Rack::MiniProfiler)
::Rack::MiniProfiler.profile_method(ActionController::Base, :process) {|action| "Executing action: #{action}"}
::Rack::MiniProfiler.profile_method(ActionView::Template, :render) {|x,y| "Rendering: #{@virtual_path}"}

# monkey patch away an activesupport and json_pure incompatability
# http://pivotallabs.com/users/alex/blog/articles/1332-monkey-patch-of-the-day-activesupport-vs-json-pure-vs-ruby-1-8
if JSON.const_defined?(:Pure)
  class JSON::Pure::Generator::State
    include ActiveSupport::CoreExtensions::Hash::Except
  end
end
