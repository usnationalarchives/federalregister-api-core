class Content::PublicInspectionImporter::JobQueue
  attr_reader :session_token

  def initialize(options)
    @session_token = options.fetch(:session_token)
  end

  def enqueue(document_number, pdf_url)
    redis.sadd(redis_set, document_number)
    Resque.enqueue PublicInspectionDocumentFileImporter,
      :document_number => document_number,
      :pdf_url => pdf_url,
      :api_session_token => session_token,
      :redis_set => redis_set
  end

  def empty?
    redis.scard(redis_set) == 0
  end

  def poll_until_complete(options={})
    timeout = options.fetch(:timeout)

    timeout.to_i.times do
      if empty?
        clear
        yield
      else
        sleep(1)
      end
    end
  end

  def pending_document_numbers
    redis.smembers(redis_set)
  end

  def clear
    redis.del(redis_set)
  end

  private

  def redis_set
    @redis_set ||= "pi_import:#{Process.pid}:#{SecureRandom.hex(10)}"
  end

  def redis
    @redis ||= Redis.new
  end
end
