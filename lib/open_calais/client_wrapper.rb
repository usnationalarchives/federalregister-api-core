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
      open_calais.enrich(text)
    end

    def open_calais
      OpenCalais::Client.new(:api_key => SECRETS['api_keys']['open_calais'])
    end

  end
end
