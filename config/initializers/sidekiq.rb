redis_url = "redis://#{Rails.application.secrets[:redis][:host]}:#{Rails.application.secrets[:redis][:port]}/#{Rails.application.secrets[:redis][:db]}"

module Sidekiq::Logger::Formatters
  class LokiJSON < Base
    def call(severity, time, program_name, message)
      hsh = {
        ts: time.utc.iso8601(3),
        pid: ::Process.pid,
        tid: tid,
        lvl: severity,
        msg: message,
        env: Rails.env
      }

      hsh.merge!(ctx) unless ctx.empty?

      if ctx[:enqueued_at] && ctx[:started_at]
        hsh[:queue_time] = Time.parse(ctx[:started_at]) - Time.parse(ctx[:enqueued_at])
      end

      if RequestStore[:memory_usage].present?
        hsh[:memory_usage] = RequestStore[:memory_usage]
      end

      Sidekiq.dump_json(hsh) << "\n"
    end
  end
end

require_relative "../../lib/sidekiq/ofr_job_logger"
require_relative "../../lib/sidekiq/sidekiq_request_store"
require_relative "../../lib/sidekiq/sidekiq_memory_logger"

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::SidekiqRequestStore
    chain.add Sidekiq::SidekiqMemoryLogger
  end

  config.log_formatter = Sidekiq::Logger::Formatters::LokiJSON.new
  config.options[:job_logger] = Sidekiq::OfrJobLogger
  config.on(:heartbeat) do
    Sidekiq.logger.debug "first heartbeat or recovering from an outage and need to reestablish our heartbeat"
  end

  config.redis = { url: redis_url, reconnect: 0}
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url, reconnect: 0}
end

require "sidekiq/throttled"
begin
  Sidekiq::Throttled.setup!
rescue ArgumentError
  # Sidekiq::Throttled.setup! throws "ArgumentError: empty :queues"
  # but works correctly on initialization
end

Sidekiq::Throttled::Registry.add(:reg_gov_api, **{
  threshold: {
    limit:  Settings.regulations_dot_gov.throttle.at,
    period: Settings.regulations_dot_gov.throttle.per.send(:seconds)
  }
})
