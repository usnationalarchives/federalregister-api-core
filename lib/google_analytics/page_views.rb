module GoogleAnalytics
  class PageViews < GoogleAnalytics::Base
    def counts(args = {})
      args = default_args.deep_merge(args)

      response = connection.post('v4/reports:batchGet') do |request|
        request.headers = auth.apply(request.headers)
        request.body = request_body(args)
      end

      JSON.parse(response.body)
    end

    private

    def default_args
      {
        end_date: Date.current,
        page_token: 0, #offset when paginating
        page_size: 10000,
        start_date: Date.current - 1.month,
      }
    end

    def request_body(args)
      body = {
        reportRequests: [{
          dateRanges: [
            {
              startDate: args[:start_date],
              endDate: args[:end_date],
            }
          ],
          viewId: VIEW_ID,
          metrics: [{ expression: "ga:pageviews" }],
          dimensions: [{ name: "ga:pagePath" }],
          pageSize: args[:page_size],
          pageToken: args[:page_token].to_s,
          hideTotals: true, # sum of counts not needed
          hideValueRanges: true, # range of values not need
        }]
      }

      # filters take the form of an array of hashes like:
      # [{
      #   filters: [
      #     {
      #       dimensionName: "ga:pagePath",
      #       operator: "REGEXP",
      #       expressions: ["^/documents/"]
      #     }
      #   ]
      # }]
      if args[:dimension_filters]
        body[:reportRequests].first.merge!(dimensionFilterClauses: Array(args[:dimension_filters]))
      end

      body.to_json
    end
  end
end
