REDIS_CONNECTION_SETTINGS = {
  :db   => SECRETS['redis']['db'],
  :host => SECRETS['redis']['host'],
  :port => SECRETS['redis']['port']
}

$redis = Redis.new(REDIS_CONNECTION_SETTINGS)
Resque.redis = $redis

if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    # We're in smart spawning mode.
    if forked
      $redis.client.disconnect
      $redis = Redis.new(REDIS_CONNECTION_SETTINGS)
      Resque.redis = $redis
    end
  end
end
