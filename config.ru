require "./config/environment"

use Rails::Rack::Static
run ActionController::Dispatcher.new
