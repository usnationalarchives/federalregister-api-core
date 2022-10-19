class TableOfContentsRecompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include CacheUtils

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!

    Content::TableOfContentsCompiler.perform(date)

    # Clear caching
    date = date.is_a?(Date) ? date : Date.parse(date)
    purge_cache("^/documents/#{date.strftime("%Y/%m/%d")}")
    if date == Date.current
      purge_cache("^/documents/current")
    end
  end
end
