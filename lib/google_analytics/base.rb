module GoogleAnalytics
  class Base
    # GA view id for FR
    VIEW_ID = '34995569'

    private

    def auth
      google_api_scopes = %w(
        https://www.googleapis.com/auth/analytics.readonly
      )
      Google::Auth.get_application_default(google_api_scopes)
    end

    def connection
      Faraday::Connection.new(
        'https://analyticsreporting.googleapis.com',
        headers: {'Content-Type' => 'application/json'}
      ) do |faraday|
        faraday.adapter  Faraday.default_adapter
      end
    end

    def log(msg)
      logger.info("[#{Time.current}] #{msg}")
    end

    def logger
      @logger ||= Logger.new("#{Rails.root}/log/google_analytics_api.log")
    end
  end
end
