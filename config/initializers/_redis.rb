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


IMPORT_SIDEKIQ_REDIS_CONNECTION_SETTINGS = {
  db: Settings.redis_import.db,
  host: Settings.redis.host || Rails.application.credentials.dig(:redis, :host),
  port: Settings.redis.port
}
$import_redis = Sidekiq::RedisConnection.create(IMPORT_SIDEKIQ_REDIS_CONNECTION_SETTINGS)
