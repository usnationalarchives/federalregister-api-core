class CacheClearer
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include CacheUtils

  sidekiq_options :queue => :high_priority, :retry => 0

  def perform(paths)
    Array.wrap(paths).each do |path|
      purge_cache(path)
    end
  end

end
