REDIS_CONNECTION_SETTINGS = {
  db: Settings.redis.db,
  host: Settings.redis.host || Rails.application.credentials.dig(:redis, :host),
  port: Settings.redis.port
}

if Rails.env.test?
  $redis = MockRedis.new
else
  $redis = Redis.new(REDIS_CONNECTION_SETTINGS)
end
