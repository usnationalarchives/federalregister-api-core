redis_url = "redis://#{Rails.application.secrets[:redis][:host]}:#{Rails.application.secrets[:redis][:port]}/#{Rails.application.secrets[:redis][:db]}"

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
  config.log_formatter = Sidekiq::Logger::Formatters::JSON.new
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

require "sidekiq/throttled"
Sidekiq::Throttled.setup!

Sidekiq::Throttled::Registry.add(:reg_gov_api, **{
  threshold: {
    limit:  SETTINGS['regulations_dot_gov']['throttle']['at'],
    period: SETTINGS['regulations_dot_gov']['throttle']['per'].send(:seconds)
  }
})
