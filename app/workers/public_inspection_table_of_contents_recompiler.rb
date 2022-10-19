class PublicInspectionTableOfContentsRecompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include CacheUtils

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!
    
    TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
    TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)

    # Clear caching
    date = date.is_a?(Date) ? date : Date.parse(date)
    purge_cache("^/public-inspection/#{date.strftime("%Y/%m/%d")}")
    if date == Date.current
      purge_cache("^/public-inspection/current")
    end
  end

end
