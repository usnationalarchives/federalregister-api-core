class PageViewHistoricalSetUpdater
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker
  include CacheUtils
  include PageViewCountUtils
  sidekiq_options :queue => :place_determiner, :retry => 6
  sidekiq_throttle(**{
    # Allow maximum 1 concurrent jobs of this class at a time.
    :concurrency => { :limit => 1 },
  })

  def perform(start_date,end_date, page_view_type_id, use_pre_ga_4_api)
    ActiveRecord::Base.clear_active_connections!
    @page_view_type = PageViewType.find(page_view_type_id)
    @use_pre_ga_4_api = use_pre_ga_4_api
    begin
      update_counts(
        Date.parse(start_date),
        Date.parse(end_date),
        page_view_type.historical_set,
        temp_set
      )
    ensure
      # If a failure occurs (eg rate limit, service unavailable, etc.) we want to make sure the redis temp set is cleared.
      $redis.del(temp_set)
    end
    clear_cache
  end

  private

  attr_reader :page_view_type

  def temp_set
    "bulk_google_analytics_temp_set:#{SecureRandom.uuid}"
  end

end
