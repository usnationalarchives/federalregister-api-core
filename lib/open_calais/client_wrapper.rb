module OpenCalais
  class ClientWrapper

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
        Honeybadger.notify(error_message: "#{e.inspect}: Request Size in Bytes: #{text.bytesize}")
      rescue StandardError => e
        Honeybadger.notify(error_message: "Open Calais API Failure for text: #{text}. Error: #{e.inspect}")
      end
    end

    def open_calais
      OpenCalais::Client.new(:api_key => Rails.application.secrets[:api_keys][:open_calais])
    end

  end
end
