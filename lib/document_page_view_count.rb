class DocumentPageViewCount
  extend Memoist
  include CacheUtils

  PER_PAGE = 10000

  HISTORICAL_SET = "doc_counts:historical"
  TEMP_SET = "doc_counts:in_progress"
  TODAY_SET = "doc_counts:today"

  def self.count_for(document_number)
    $redis.pipelined do
      $redis.zscore HISTORICAL_SET, document_number
      $redis.zscore TODAY_SET, document_number
    end.compact.map{|count| count.to_i}.sum
  end

  def update_all
    # reset all counts
    $redis.del(HISTORICAL_SET)
    $redis.del(TEMP_SET)
    $redis.del(TODAY_SET)

    # work through counts one year at a time
    # so as to keep requests reasonable (otherwise risk 503s -
    # heavy lift on the GA side to calculate these counts)
    (2010..Date.current.year).to_a.reverse.each do |year|
      start_date = Date.new(year,1,1)
      end_date = start_date.end_of_year

      # don't include today (it has it's own calculation)
      end_date = end_date - 1.day if year == Date.current.year

      update_counts(start_date, end_date, HISTORICAL_SET)
    end

    # update today's counts
    update_counts(Date.current, Date.current, TODAY_SET)

    clear_cache
  end

  def update_counts_for_today
    # this is run once per hour to update the current days counts
    # as such at midnight we want to finish calculating yesterdays count
    # and then collapse those counts into the historical counts
    if Time.current.hour == 0
      update_counts(Date.current-1.day, Date.current-1.day, TODAY_SET)
      collapse_counts
    else
      update_counts(Date.current, Date.current, TODAY_SET)
    end

    clear_cache
  end

  def clear_cache
    purge_cache('/api/v1/documents')
    purge_cache('/documents/')
  end

  def update_counts(start_date, end_date, set)
    current_time = Time.current
    processed_results = 0

    log("processing: {start_date: #{start_date}, end_date: #{end_date}}")

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
          $redis.zincrby(TEMP_SET, visits, document_number)
        end
      end

      # increment our processed results count
      processed_results += PER_PAGE
    end

    if set == TODAY_SET
      $redis.rename TEMP_SET, set
    else
      $redis.zunionstore(HISTORICAL_SET, [TEMP_SET, HISTORICAL_SET])
      $redis.del(TEMP_SET)
    end

    $redis.set "doc_counts:current_as_of", current_time
  end

  def collapse_counts
    $redis.zunionstore(HISTORICAL_SET, [TODAY_SET, HISTORICAL_SET])
    $redis.del(TODAY_SET)
  end

  private

  def log(msg)
    logger.info(msg)
    puts msg if ENV['VERBOSE'] == "1"
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/document_page_counts.log")
  end

  # convert the GA response data structure into document_number, count
  def counts_by_document_number(rows)
    rows.each do |row|
      url = row["dimensions"][0]
      count = row["metrics"][0]["values"][0].to_i

      # ignore aggregate dimensions like "(other)"
      # and extract document_number
      document_number = url =~ /^\/(articles|documents)\// ? url.split('/')[5] : nil

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
    )["reports"].first["data"]["rowCount"]
  end
  memoize :total_results


  def page_views(args={})
    GoogleAnalytics::PageViews.new.counts(
      default_args.merge(args)
    )
  end

  def default_args
    {
      dimension_filters: dimension_filters
    }
  end

  def dimension_filters
    [
      {
        filters: [
          {
            dimensionName: "ga:pagePath",
            operator: "REGEXP",
            expressions: ["^/(documents/|articles/)"]
          }
        ]
      }
    ]
  end
end
