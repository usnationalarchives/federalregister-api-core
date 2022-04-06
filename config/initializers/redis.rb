REDIS_CONNECTION_SETTINGS = {
  :db   => Rails.application.secrets[:redis][:db],
  :host => Rails.application.secrets[:redis][:host],
  :port => Rails.application.secrets[:redis][:port]
}

if Rails.env.test?
  $redis = MockRedis.new
else
  $redis = Redis.new(REDIS_CONNECTION_SETTINGS)
end
