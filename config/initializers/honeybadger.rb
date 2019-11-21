require 'resque'
require 'resque-honeybadger'

require 'resque/failure/multiple'
require 'resque/failure/redis'

Resque::Failure::Multiple.classes = [Resque::Failure::Redis, Resque::Failure::Honeybadger]
Resque::Failure.backend = Resque::Failure::Multiple
