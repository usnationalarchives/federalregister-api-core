class Ga4Client

  def counts(args={})
    response = ga4_api_request(default_args.deep_merge(args))
  end

  private

  PROPERTY_ID = 347640680
  def ga4_api_request(args)
    # Initialize the client
    client = Google::Apis::AnalyticsdataV1beta::AnalyticsDataService.new

    # Authenticate
    client.authorization = credentials
    if verbose?
      client.check_property_compatibility("properties/#{PROPERTY_ID}")
    end

    # Run the batch report
    client.batch_property_run_reports(
      "properties/#{PROPERTY_ID}",
      Google::Apis::AnalyticsdataV1beta::BatchRunReportsRequest.new(
        requests: [request_body(args)]
      )
    )
  end

  def verbose?
    false
  end

  def credentials
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open('config/google_analytics_4_credentials.json'),
      scope: 'https://www.googleapis.com/auth/analytics.readonly'
    )
  end

  def default_args
    {
      end_date: Date.current,
      offset: 0, #offset when paginating
      limit: 10000,
      start_date: Date.current - 1.month,
    }
  end

  def request_body(args)
    Google::Apis::AnalyticsdataV1beta::RunReportRequest.new(
      date_ranges: [
        Google::Apis::AnalyticsdataV1beta::DateRange.new(
          start_date: args.fetch(:start_date),
          end_date: args.fetch(:end_date)
        )
      ],
      dimensions: dimensions.map { |name| Google::Apis::AnalyticsdataV1beta::Dimension.new(name: name) },
      metrics: metrics.map { |name| Google::Apis::AnalyticsdataV1beta::Metric.new(name: name) },
      limit: args[:limit],
      offset: args[:offset],
      dimension_filter: Google::Apis::AnalyticsdataV1beta::FilterExpression.new(
        filter: Google::Apis::AnalyticsdataV1beta::Filter.new(
          field_name: "pagePath",
          string_filter: Google::Apis::AnalyticsdataV1beta::StringFilter.new(
            match_type: "FULL_REGEXP",
            value: args.fetch(:ga4_url_regex) #TODO: Confirm this parameter works with GA4
          )
        )
      )
    )
  end

  def dimensions
    ["pagePath"]
  end

  def metrics
    ["screenPageViews"]
  end

end
