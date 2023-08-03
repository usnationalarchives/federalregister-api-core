module OpenCalais
  class ClientWrapper
    class RequestLimit < StandardError; end
    class OpenCalaisRequestFailure < StandardError; end
    class RequestSizeTooLarge < StandardError; end
    class InternalServerError < StandardError; end

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
        raw_response = @enriched_response.raw
        if raw_response.status != 200
          raise OpenCalaisRequestFailure.new("#{raw_response.status}: #{raw_response.reason_phrase}")
        end
        @enriched_response
      rescue Faraday::ClientError => e
        case e.response.fetch(:status)
        when 413
          raise RequestSizeTooLarge.new("Request Size Too Large: #{text.bytesize/1024.to_f}KB")
        when 429
          # "An HTTP 429 error is generated in when the daily request quota, or the per-second request quota is exceeded. "
          raise RequestLimit.new(e.inspect)
        when 500
          raise InternalServerError.new(e.inspect)
        else
          raise e
        end
      end
    end

    def open_calais
      OpenCalais::Client.new(:api_key => Rails.application.secrets[:api_keys][:open_calais])
    end

  end
end
