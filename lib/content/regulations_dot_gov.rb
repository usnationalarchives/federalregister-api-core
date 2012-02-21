module Content
  class RegulationsDotGov
    class RecordNotFound < HTTParty::ResponseError; end
    class ServerError < HTTParty::ResponseError; end

    include HTTParty
    base_uri 'http://www.regulations.gov/api/'

    def initialize(api_key)
      @api_key = api_key
    end

    def find_by_document_number(document_number)
      begin
        fetch_by_document_number(document_number)
      rescue RecordNotFound, ServerError => e
        revised_document_number = pad_document_number(document_number) 
        if revised_document_number != document_number
          fetch_by_document_number(revised_document_number)
        else
          nil
        end
      end  
    end

    private

    def pad_document_number(document_number)
      part_1, part_2 = document_number.split(/-/, 2)
      sprintf("%s-%05d", part_1, part_2.to_i)
    end

    def fetch_by_document_number(document_number)
      response = self.class.get('/getdocument/v1.json', :query => {:api_key => @api_key, :FR => document_number})
      Document.new(response.parsed_response["document"])
    end

    def self.get(url, options)
      response = super

      case response.code
      when 200
        response
      when 404
        raise RecordNotFound.new(response)
      when 500
        raise ServerError.new(response)
      else
        raise HTTParty::ResponseError.new(response)
      end
    end

    class Document
      def initialize(raw_attributes)
        @raw_attributes = raw_attributes
        @metadata = {}
        @raw_attributes["metadata"]["entry"].each do |hsh|
          @metadata[ hsh["@name"] ] = hsh["$"]
        end
      end

      def document_id
        @raw_attributes['documentId']
      end

      def comment_due_date
        val = @metadata["Comment Due Date"]
        if val.present?
          DateTime.parse(val)
        end
      end

      def comment_url
        "http://www.regulations.gov/#!submitComment;D=#{document_id}"
      end

      def url
        "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
      end
    end
  end
end
