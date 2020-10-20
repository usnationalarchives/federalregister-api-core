class PageViewCount
  extend Memoist
  include CacheUtils

  PER_PAGE = 10000

  def initialize(page_view_type)
    @page_view_type = page_view_type
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
      update_counts(date_range.first, date_range.last, page_view_type.historical_set)
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

  def clear_cache
    page_view_type.cache_expiry_urls.each{|url| purge_cache(url) }
  end

  def update_counts(start_date, end_date, set)
    current_time = Time.current
    processed_results = 0

    log("processing: {start_date: #{start_date}, end_date: #{end_date}}")
    log("#{total_results(start_date, end_date)} results need processing")

    # work through counts in batches of PER_PAGE
    while processed_results < total_results(start_date, end_date) do
      log("processed_results: #{processed_results}/#{total_results(start_date, end_date)}")

      # get counts
      response = page_views(
        start_date: start_date,
        end_date: end_date,
        per_page: PER_PAGE,
        page_token: processed_results
      )

      results = response["reports"].first["data"]["rows"]

      # increment our counts hash in redis
      $redis.pipelined do
        counts_by_document_number(results) do |document_number, visits|
          $redis.zincrby(page_view_type.temp_set, visits, document_number)
        end
      end

      # increment our processed results count
      processed_results += PER_PAGE
    end

    if total_results(start_date, end_date) > 0
      if set == page_view_type.today_set
        # store a copy of the set each hour for internal analysis
        $redis.zunionstore("#{page_view_type.namespace}:#{Date.current.to_s(:iso)}:#{Time.current.hour}", [page_view_type.temp_set])
        $redis.rename(page_view_type.temp_set, set)
      elsif set == page_view_type.yesterday_set
        $redis.rename(page_view_type.temp_set, set)
        $redis.del(page_view_type.temp_set)
      else
        $redis.zunionstore(page_view_type.historical_set, [page_view_type.temp_set, page_view_type.historical_set])
        $redis.del(page_view_type.temp_set)
      end
    end

    $redis.set page_view_type.current_as_of, current_time
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

  def log(msg)
    logger.info("[#{Time.current}] #{msg}")
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/google_analytics_api.log")
  end

  # convert the GA response data structure into document_number, count
  def counts_by_document_number(rows)
    rows.each do |row|
      url = row["dimensions"][0]
      count = row["metrics"][0]["values"][0].to_i

      # ignore aggregate dimensions like "(other)"
      # and extract document_number
      document_number = url =~ page_view_type.google_analytics_url_regex ? url.split('/')[page_view_type.document_number_position_index] : nil

      # only record page view data if we have a valid looking document number
      # (e.g. with a '-' in it)
      if document_number && document_number.include?('-')
        yield document_number, count
      end
    end
  end

  def total_results(start_date, end_date)
    page_views(
      page_size: 1,
      start_date: start_date,
      end_date: end_date
    )["reports"].first["data"]["rowCount"].to_i
  end
  memoize :total_results


  def page_views(args={})
    GoogleAnalytics::PageViews.new.counts(
      default_args.merge(args)
    )
  end

  def default_args
    {
      dimension_filters: dimension_filters,
    }
  end

  def dimension_filters
    [
      {
        filters: [
          {
            dimensionName: "ga:pagePath",
            operator: "REGEXP",
            expressions: page_view_type.filter_expressions
          }
        ]
      }
    ]
  end

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
        elsif (date_range.first < Date.current)
          date_ranges << date_range
        end
      end
    end
  end

end
