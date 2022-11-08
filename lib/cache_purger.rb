class CachePurger
  include CacheUtils

  def on_complete(status, options)
    Array.wrap(options['paths']).each do |path|
      purge_cache(path)
    end
  end
end
