module GoogleAnalytics
  class PageViews < GoogleAnalytics::Base
    RETRIES = 3
    RETRY_DELAY = 30

    def counts(args = {})
      response = ga_api_request(
        default_args.deep_merge(args)
      )

      JSON.parse(response.body)
    end

    private

    def ga_api_request(args)
      retries = RETRIES

      while retries > 0 do
        request_start = Time.current

        response = connection.post('v4/reports:batchGet') do |request|
          request.headers = auth.apply(request.headers)
          request.body = request_body(args)
          request.options.open_timeout = 240
          request.options.timeout = 240
        end

        request_end = Time.current
        log("GA request took #{request_end - request_start}")

        if response.status == 200
          return response
        else
          retries -= 1

          if retries > 0
            log("Response status was #{response.status}, retrying in #{RETRY_DELAY} seconds. Retries left: #{retries}.")
            sleep(RETRY_DELAY)
          else
            log("Unable to successfully get a response from GA. No retries left!")
            raise "GAConnectionError"
          end
        end
      end
    end

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
