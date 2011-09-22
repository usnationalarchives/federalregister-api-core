module Content
  class PublicInspectionImporter
    def self.perform
      curl = Curl::Easy.new('http://www.ofr.gov/inspection.aspx')
      curl.follow_location = true
      curl.perform

      parser = Nokogiri::HTML::SAX::Parser.new(Parser.new)
      parser.parse(curl.body_str)
    end

    def self.import(attributes)
      pi = new(attributes)
      pi.save
    end

    def initialize(attributes)
      @pi = PublicInspectionDocument.find_or_initialize_by_document_number(attributes.delete(:document_number))
      attributes.each_pair do |attr,val|
        send("#{attr}=", val)
      end
    end

    def save
      @pi.save
    end

    [:document_number, :granule_class, :toc_subject, :toc_doc, :filed_at, :publication_date, :docket_id].each do |attr|
      define_method "#{attr}=" do |val|
        @pi.send("#{attr}=", val)
      end
    end

    def details=(val)
      val.sub!(/^\[/,'').sub!(/\]$/,'')
      val.split(/\s*;\s*/).each do |part|
        case part
        when /Filed: (.+)/
          self.filed_at = $1
        when /Publication Date: (.+)/
          self.publication_date = $1
        when /Docket No. (.+)/
          self.docket_id = $1
        else
          # TODO: internal_docket_id ?
          # TODO: multiple docket numbers?
        end
      end
    end

    def agency=(val)
      if val.present?
        agency_name = AgencyName.find_or_create_by_name(val)
        @pi.agency_names << agency_name unless @pi.agency_names.include?(agency_name)
      else
        @pi.agency_names = []
      end
    end

    def url=(url)
      if not_already_downloaded? || etag_from_head(url) != @pi.pdf_etag
        path = File.join(Dir.tmpdir, File.basename(url))
        curl = Curl::Easy.download(url, path)
        headers = HttpHeaders.new(curl.header_str)
        @pi.pdf_file_name = @pi.pdf_etag = headers.etag
        @pi.pdf = File.new(path)
        File.delete(path)
      end
    end

    def filing_type=(val)
      @pi.special_filing = val == 'special'
    end

    def not_already_downloaded?
      @pi.pdf.url.blank?
    end

    def etag_from_head(url)
      curl = Curl::Easy.http_head(url)
      headers = HttpHeaders.new(curl.header_str)
      headers.etag
    end

    class Parser < Nokogiri::XML::SAX::Document
      GRANULE_CLASSES = {
        "NOTICES" => "NOTICE",
        "RULES" => "RULE",
        "PROPOSED RULES" => "PRORULE",
        "PRESIDENTIAL DOCUMENTS" => "PRESDOCU"
      }

      def start_element name, raw_attributes = []
        attributes = Hash[*raw_attributes]

        # ensure we're only parsing the main document body
        case attributes['id']
        when 'content-body'
          @in_body = true
        when 'Footer'
          @in_body = false
        end
        return unless @in_body

        case name
        when 'blockquote'
          @context = :document_number_or_toc_doc
        when 'p'
          @context = :toc_subject
        when 'b'
          @context = :agency_or_granule_class
        when 'a'
          if attributes['href'] && attributes['target']
            @url = attributes['href']
            @context = :initial_details if attributes['href']
          elsif ['special', 'regular'].include?(attributes['name'])
            @filing_type = attributes['name']
          end
        end
      end

      def characters(str)
        # get rid of leading/trailing whitespace and skip blank/&nbsp; nodes
        str.strip!
        return if str == '' || str == "\302\240"

        case @context
        when :agency_or_granule_class
          if GRANULE_CLASSES[str]
            @granule_class = GRANULE_CLASSES[str]
          else
            @agency = str
          end
        when :document_number_or_toc_doc
          if @document_number
            @toc_doc = @document_number
          end
          @document_number = str
        when :toc_subject
          @toc_subject = str
          @toc_doc = nil
        when :initial_details
          @details = str
          new_context = :final_details
        when :final_details
          @details += str
          Content::PublicInspectionImporter.import(
            :filing_type     => @filing_type,
            :details         => @details,
            :agency          => @agency,
            :granule_class   => @granule_class,
            :document_number => @document_number,
            :toc_subject     => @toc_subject,
            :toc_doc         => @toc_doc,
            :url             => @url
          )
          @document_number = nil
        end

        @context = new_context
      end
    end
  end
end
