class PageViewCount
  include CacheUtils
  include PageViewCountUtils


  def initialize(page_view_type)
    @page_view_type = page_view_type
  end

  def self.batch_count_for(document_numbers, page_view_type)
    results = $redis.pipelined do
      document_numbers.each do |document_number|
        $redis.zscore page_view_type.historical_set, document_number
        $redis.zscore page_view_type.yesterday_set, document_number
        $redis.zscore page_view_type.today_set, document_number
        $redis.get page_view_type.current_as_of
      end
    end

    results.
      in_groups_of(4).
      zip(document_numbers).
      each_with_object({}) do |((zscore_historical_set, zscore_yesterday_set, zscore_today_set, current_as_of), document_number), hsh|
        hsh[document_number] = {
          count:      [zscore_historical_set, zscore_yesterday_set, zscore_today_set].compact.sum,
          last_updated: current_as_of
        }
      end
  end

  def self.count_for(document_number, page_view_type)
    $redis.pipelined do
      $redis.zscore page_view_type.historical_set, document_number
      $redis.zscore page_view_type.yesterday_set, document_number
      $redis.zscore page_view_type.today_set, document_number
    end.compact.map{|count| count.to_i}.sum
  end

  def self.last_updated(page_view_type)
    $redis.get page_view_type.current_as_of
  end

  def update_all(start_year=2010, end_year=Date.current.year, reset_counts=true)
    if reset_counts
      $redis.del(page_view_type.historical_set)
      $redis.del(page_view_type.yesterday_set)
    end

    $redis.del(page_view_type.temp_set)
    $redis.del(page_view_type.today_set)

    # work through counts one quarter at a time
    # so as to keep requests reasonable (otherwise risk 503s -
    # heavy lift on the GA side to calculate these counts)
    date_ranges(start_year, end_year).each do |date_range|
      PageViewHistoricalSetUpdater.perform_async(
        date_range.first.to_s(:iso),
        date_range.last.to_s(:iso),
        page_view_type.id
      )
    end

    # update today's counts
    update_counts(Date.current, Date.current, page_view_type.today_set)

    clear_cache
  end

  def update_counts_for_today


    if Time.current.hour == 0
      # this is run once every 2 hours to update the current days counts
      # as such at midnight we want to finish calculating yesterdays count
      # and then move those counts into yesterdays counts
      update_counts(Date.current-1.day, Date.current-1.day, page_view_type.today_set)
      move_today_to_yesterday
    elsif Time.current.hour == 6
      # at 6 am we finalize yesterdays counts (GA applies post processing, etc)
      # and then merge those into the historical counts
      update_counts(Date.current-1.day, Date.current-1.day, page_view_type.yesterday_set)
      collapse_counts
    else
      update_counts(Date.current, Date.current, page_view_type.today_set)
    end

    clear_cache
  end

  def move_today_to_yesterday
    $redis.rename(page_view_type.today_set, page_view_type.yesterday_set)
    $redis.del(page_view_type.today_set)
  end

  def collapse_counts
    $redis.zunionstore(page_view_type.historical_set, [page_view_type.yesterday_set, page_view_type.historical_set])
    $redis.del(page_view_type.yesterday_set)
  end


  private

  attr_reader :page_view_type

  GOOGLE_ANALYTICS_START_DATE = Date.new(2010,7,1)
  def date_ranges(start_year, end_year)
    (start_year..end_year).each_with_object([]) do |year, date_ranges|
      quarters = [
        (Date.new(year,1,1)..Date.new(year,3,31)),
        (Date.new(year,4,1)..Date.new(year,6,30)),
        (Date.new(year,7,1)..Date.new(year,9,30)),
        (Date.new(year,10,1)..Date.new(year,12,31)),
      ].each do |date_range|
        if date_range.include? Date.current
          # don't include today (it has it's own calculation)
          date_ranges << (date_range.first..Date.current - 1.day)
        elsif (date_range.first < Date.current) && (date_range.first >= GOOGLE_ANALYTICS_START_DATE)
          date_ranges << date_range
        end
      end
    end
  end

end
