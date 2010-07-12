module CacheUtils
  def purge_cache(regexp)
    Client.instance.purge(regexp)
  end
  
  class Client
    include Singleton
    
    def purge(regexp)
      client.purge(:url, regexp)
    end
    
    private
    
    def client
      @client ||= Varnish::Client.new RAILS_ENV == 'development' ? '127.0.0.1:6082' : 'proxy.fr2.ec2.internal:6082'
    end
    
  end
end