module PageViewCountUtils
  extend Memoist
  PER_PAGE = 10000

  def update_counts(start_date, end_date, set, temp_set = page_view_type.temp_set)
    current_time = Time.current
    processed_results = 0

    log("processing: {start_date: #{start_date}, end_date: #{end_date}}")
    log("#{total_results(start_date, end_date)} results need processing")

    # work through counts in batches of PER_PAGE
    while processed_results < total_results(start_date, end_date) do
      log("processed_results: #{processed_results}/#{total_results(start_date, end_date)}")

      # get counts
      if use_ga4?
        response = page_views(
          start_date: start_date.to_s(:iso),
          end_date: end_date.to_s(:iso),
          limit: PER_PAGE,
          offset: processed_results
        )
      else
        response = page_views(
          start_date: start_date.to_s(:iso),
          end_date: end_date.to_s(:iso),
          per_page: PER_PAGE,
          page_token: processed_results
        )
      end

      if use_ga4?
        results = response.reports.first.rows
      else
        results = response["reports"].first["data"]["rows"]
      end

      # increment our counts hash in redis
      $redis.pipelined do
        counts_by_document_number(results) do |document_number, visits|
          $redis.zincrby(temp_set, visits, document_number)
        end
      end

      # increment our processed results count
      processed_results += PER_PAGE
    end

    if total_results(start_date, end_date) > 0
      if set == page_view_type.today_set
        $redis.rename(temp_set, set)
      elsif set == page_view_type.yesterday_set
        $redis.rename(temp_set, set)
        $redis.del(temp_set)
      else
        $redis.zunionstore(page_view_type.historical_set, [temp_set, page_view_type.historical_set])
        $redis.del(temp_set)
      end
    end

    $redis.set page_view_type.current_as_of, current_time
  end


  private

  attr_reader :use_pre_ga_4_api

  def log(msg)
    logger.info("[#{Time.current}] #{msg}")
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/google_analytics_api.log")
  end

  # convert the GA response data structure into document_number, count
  def counts_by_document_number(rows)
    rows.each do |row|
      url = row

      if use_ga4?
        url = row.dimension_values.first.value
        count = row.metric_values.first.value.to_i
      else
        url = row["dimensions"][0]
        count = row["metrics"][0]["values"][0].to_i
      end

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
    if use_ga4?
      page_views(
        limit: 1,
        start_date: start_date.to_s(:iso),
        end_date: end_date.to_s(:iso)
      ).reports.first.row_count.to_i
    else
      page_views(
        page_size: 1,
        start_date: start_date.to_s(:iso),
        end_date: end_date.to_s(:iso)
      )["reports"].first["data"]["rowCount"].to_i
    end
  end
  memoize :total_results

  def use_ga4?
    if use_pre_ga_4_api
      false
    else
      true
    end
  end

  def page_views(args={})
    if use_ga4?
      Ga4Client.new.counts(
        default_args.merge(args)
      )
    else
      GoogleAnalytics::PageViews.new.counts(
        default_args.merge(args)
      )
    end
  end

  def default_args
    if use_ga4?
      {
        ga4_url_regex: page_view_type.ga4_url_regex
      }
    else
      {
        dimension_filters: dimension_filters,
      }
    end
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

  def clear_cache
    page_view_type.cache_expiry_urls.each{|url| purge_cache(url) }
  end

end
