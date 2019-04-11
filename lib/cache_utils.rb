module CacheUtils
  def purge_cache(regexp)
    Client.instance.purge(regexp)
  end
  module_function :purge_cache

  class Client
    include Singleton

    def purge(regexp)
      Rails.logger.info("Expiring from varnish: '#{regexp}'...")
      begin
        client.send(:cmd, "ban req.url ~ #{regexp}")
      rescue SocketError => e
        Rails.logger.warn("Couldn't connect to varnish to expire '#{regexp}'")
        Honeybadger.notify(e)
      end
    end

    private

    def client
      host = "#{SETTINGS['varnish']['host']}:#{SETTINGS['varnish']['port']}"
      @client ||= Varnish::Client.new(host, :timeout => 60)
    end
  end
end
