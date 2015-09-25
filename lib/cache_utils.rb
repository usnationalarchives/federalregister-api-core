module CacheUtils
  def purge_cache(regexp)
    Client.instance.purge(regexp)
  end

  class Client
    include Singleton

    def purge(regexp)
      Rails.logger.info("Expiring from varnish: '#{regexp}'...")
      begin
        client.purge(:url, regexp)
      rescue SocketError => e
        Rails.logger.warn("Couldn't connect to varnish to expire '#{regexp}'")
      end
    end

    private

    def client
      host = RAILS_ENV == 'development' ? '127.0.0.1:6082' : 'proxy.fr2.ec2.internal:6082'
      @client ||= Varnish::Client.new(host, :timeout => 60)
    end

  end
end
