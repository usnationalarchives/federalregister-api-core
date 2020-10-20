class PageViewHistoricalSetUpdater
  include Sidekiq::Worker
  include CacheUtils
  include PageViewCountUtils
  sidekiq_options :queue => :api_core, :retry => 6

  def perform(start_date,end_date, page_view_type_id)
    ActiveRecord::Base.clear_active_connections!
    @page_view_type = PageViewType.find(page_view_type_id)
    begin
      update_counts(
        start_date,
        end_date,
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
