module OpenCalais
  class ClientWrapper
    class ConcurrentRequestLimit < StandardError; end

    def initialize(text)
      @text = text
    end

    def locations
      enriched_response.locations || []
    end

    private

    attr_reader :text

    def enriched_response
      begin
        @enriched_response ||= open_calais.enrich(text)
      rescue Faraday::ParsingError => e
        if e.response.status == 429
          raise ConcurrentRequestLimit.new(e.inspect)
        else
          Honeybadger.notify(error_message: "#{e.inspect}: Request Size in Bytes: #{text.bytesize}")
          raise e
        end
      end
    end

    def open_calais
      OpenCalais::Client.new(:api_key => Rails.application.secrets[:api_keys][:open_calais])
    end

  end
end
