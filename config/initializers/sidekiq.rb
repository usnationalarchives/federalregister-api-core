redis_url = "redis://#{Rails.application.secrets[:redis][:host]}:#{Rails.application.secrets[:redis][:port]}/#{Rails.application.secrets[:redis][:db]}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

require "sidekiq/throttled"
Sidekiq::Throttled.setup!
