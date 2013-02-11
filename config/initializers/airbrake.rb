airbrake_config = Proc.new do |config|
  config.api_key = ENV['hoptoad_api_key']
end

Airbrake.configure &airbrake_config

require 'resque/failure/multiple'
require 'resque/failure/airbrake'
require 'resque/failure/redis'

Resque::Failure::Airbrake.configure &airbrake_config
Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Airbrake]
Resque::Failure.backend = Resque::Failure::Multiple
