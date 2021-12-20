class IssueTocRegenerator
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include CacheUtils

  sidekiq_options :queue => :api_core, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!

    date = date.is_a?(Date) ? date : Date.parse(date)
    XmlTableOfContentsTransformer.perform(date)

    purge_cache("/documents/#{date.strftime("%Y/%m/%d")}")
    purge_cache("/documents/#{Time.current.to_date.strftime('%Y')}/#{Time.current.to_date.strftime('%m')}")
    purge_cache("/documents/json/#{date.strftime("%Y/%m/%d")}.json")

    if Date.current == date
      purge_cache("/documents/current")
    end
  end
end
