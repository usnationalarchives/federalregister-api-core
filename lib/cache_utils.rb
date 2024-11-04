module CacheUtils
  def purge_cache(regexp, operator: "~")
    Client.instance.purge(regexp, operator: operator)
  end
  module_function :purge_cache

  class Client
    include Singleton

    MAX_RETRIES = 1
    def purge(regexp, operator: "~")
      Rails.logger.info("Expiring from varnish: #{operator} '#{regexp}'...")
      retries = 0
      begin
        client.send(:cmd, "ban req.url #{operator} #{regexp}")
      rescue SocketError => e
        Rails.logger.warn("Couldn't connect to varnish to expire '#{operator} #{regexp}'")
        Honeybadger.notify(e)
      rescue Varnish::BrokenConnection, Errno::EPIPE, Errno::ETIMEDOUT, Timeout::Error
        if retries < MAX_RETRIES
          refresh_client!
          retry
          retries += 1
        end
      end
    end

    private

    def client
      @client ||= Varnish::Client.new(host, :timeout => 60)
    end

    def refresh_client!
      @client = Varnish::Client.new(host, :timeout => 60)
    end

    def host
      "#{Settings.varnish.host}:#{Settings.varnish.port}"
    end
  end
end
