module Content
  class RegulationsDotGov
    class ResponseError < HTTParty::ResponseError; end
    class RecordNotFound < ResponseError; end
    class ServerError < ResponseError; end

    include HTTParty
    
    if RAILS_ENV == 'production'
      base_uri 'http://www.regulations.gov/api/'
    else
      base_uri 'regstest.erulemaking.net/api/'
    end

    default_timeout 2

    def initialize(api_key)
      @api_key = api_key
    end

    def find_docket(docket_id)
      begin
        response = self.class.get('/getdocket/v1.json', :query => {:api_key => @api_key, :D => docket_id}) 
        Docket.new(self, response.parsed_response["docket"])
      rescue ResponseError
      end
    end

    def find_documents(args)
      begin
        response = self.class.get('/documentsearch/v1.json', :query => args.merge(:api_key => @api_key))
        results = response.parsed_response['searchresult']
        if results['documents'] && results['documents']['document']
          doc_details = results['documents']['document']
          doc_details = [doc_details] unless doc_details.is_a?(Array)
          doc_details.map{|raw_document| Document.new(self, raw_document)}
        else
          []
        end

      rescue ResponseError
        []
      end
    end

    def count_documents(args)
      begin
        response = self.class.get('/documentsearch/v1.json', :query => args.merge(:api_key => @api_key, :countsOnly => 1))
        response.parsed_response['searchresult']['recordCount']
      rescue ResponseError
        nil
      end
    end

    def find_by_document_number(document_number)
      begin
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
      rescue ResponseError
        nil
      end
    end

    private

    def pad_document_number(document_number)
      part_1, part_2 = document_number.split(/-/, 2)
      sprintf("%s-%05d", part_1, part_2.to_i)
    end

    def fetch_by_document_number(document_number)
      response = self.class.get('/getdocument/v1.json', :query => {:api_key => @api_key, :FR => document_number})
      Document.new(self, response.parsed_response["document"])
    end

    def self.get(url, options)
      begin
        response = super

        case response.code
        when 200
          response
        when 404
          raise RecordNotFound.new(response)
        when 500
          raise ServerError.new(response)
        else
          raise ResponseError.new(response)
        end
      rescue SocketError
        raise ResponseError.new("Hostname lookup failed")
      rescue Timeout::Error
        raise ResponseError.new("Request timed out")
      end
    end

    class GenericDocument
      attr_reader :metadata

      def initialize(client, raw_attributes)
        @client = client
        @raw_attributes = raw_attributes
        @metadata = {}
        if @raw_attributes["metadata"] && @raw_attributes["metadata"]["entry"]
          metadata_hashes = @raw_attributes["metadata"]["entry"]
          if metadata_hashes.is_a?(Hash)
            metadata_hashes = [metadata_hashes]
          end
          metadata_hashes.each do |hsh|
            @metadata[hsh["@name"]] = hsh["$"]
          end
        end
      end
    end

    class Docket < GenericDocument
      def title
        @raw_attributes['title']
      end

      def regulation_id_number
        rin = @raw_attributes['rin']

        if rin.blank? || rin == 'Not Assigned'
          nil
        else
          rin
        end
      end

      def docket_id
        @raw_attributes['docketId']
      end

      def supporting_documents
        @client.find_documents(:dktid => docket_id, :dct => 'SR', :so => 'DESC', :sb => 'docId')
      end

      def supporting_documents_count
        @client.count_documents(:dktid => docket_id, :dct => 'SR')
      end

      def comments_count
        @client.count_documents(:dktid => docket_id, :dct => 'PS')
      end
    end

    class Document < GenericDocument
      def document_id
        @raw_attributes['documentId']
      end

      def docket_id
        @raw_attributes['docketId']
      end

      def title
        @raw_attributes['title']
      end

      def comment_due_date
        val = @metadata["Comment Due Date"]
        if val.present?
          DateTime.parse(val)
        end
      end

      def comment_url
        if @raw_attributes['canCommentOnDocument']
          "http://www.regulations.gov/#!submitComment;D=#{document_id}"
        end
      end

      def url
        "http://www.regulations.gov/#!documentDetail;D=#{document_id}"
      end
    end
  end
end
