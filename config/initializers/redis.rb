REDIS_CONFIG = YAML.load_file(Rails.root + 'config/redis.yml')[Rails.env].freeze

REDIS_CONNECTION_SETTINGS = {
  :db   => REDIS_CONFIG['db'],
  :host => REDIS_CONFIG['host'],
  :port => REDIS_CONFIG['port']
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
