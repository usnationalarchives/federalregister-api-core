class IssueTocRegenerator
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :issue_reprocessor, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!

    XmlTableOfContentsTransformer.perform(date)

    include CacheUtils
    purge_cache("/documents/#{date.strftime("%Y/%m/%d")}")
    purge_cache("/documents/#{Time.current.to_date.strftime('%Y')}/#{Time.current.to_date.strftime('%m')}")
  end
end
