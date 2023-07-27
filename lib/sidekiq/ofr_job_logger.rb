require "sidekiq/job_logger"

module Sidekiq
  class OfrJobLogger < Sidekiq::JobLogger
    # Monkey patching of Sidekiq 6.4.2 implementations
    def call(item, queue)
      # mod - add start time to context
      Sidekiq::Context.add(:started_at, Time.now.utc.iso8601(3))

      # 6.4.2 implementation
      start = ::Process.clock_gettime(::Process::CLOCK_MONOTONIC)

      # mod - don't log start - we're adding that to the context above
      # @logger.info("start")

      yield

      Sidekiq::Context.add(:elapsed, elapsed(start))
      @logger.info("done")
    rescue Exception # rubocop:disable Lint/RescueException
      Sidekiq::Context.add(:elapsed, elapsed(start))
      @logger.info("fail")

      raise
    end

    def prepare(job_hash, &block)
      # If we're using a wrapper class, like ActiveJob, use the "wrapped"
      # attribute to expose the underlying thing.
      h = {
        class: job_hash["display_class"] || job_hash["wrapped"] || job_hash["class"],
        jid: job_hash["jid"]
      }
      h[:bid] = job_hash["bid"] if job_hash.has_key?("bid")
      h[:tags] = job_hash["tags"] if job_hash.has_key?("tags")
      # Added to 6.4.2 implementation
      h[:args] = job_hash["args"] if job_hash.has_key?("args")
      h[:queue] = job_hash["queue"] if job_hash.has_key?("queue")
      h[:created_at] = Time.at(job_hash["created_at"]).utc.iso8601(3) if job_hash.has_key?("created_at")
      h[:enqueued_at] = Time.at(job_hash["enqueued_at"]).utc.iso8601(3) if job_hash.has_key?("enqueued_at")

      Thread.current[:sidekiq_context] = h
      level = job_hash["log_level"]
      if level
        @logger.log_at(level, &block)
      else
        yield
      end
    ensure
      Thread.current[:sidekiq_context] = nil
    end
  end
end
