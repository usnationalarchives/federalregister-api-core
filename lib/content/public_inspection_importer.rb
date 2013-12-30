module Content
  class PublicInspectionImporter
    def self.perform
      if ENV['PI_FILE']
        html = File.read(ENV['PI_FILE'])
      else
        curl = Curl::Easy.new('http://www.ofr.gov/inspection.aspx') {|c| c.follow_location = true} 
        curl.follow_location = true
        curl.perform
        html = curl.body_str

        save_file(html)
      end

      parser = Nokogiri::HTML::SAX::Parser.new(Parser.new)
      parser.encoding = 'utf8'
      parser.parse(html)
      
      pub_date = parser.document.regular_filings_updated_at.to_date
      issue = PublicInspectionIssue.find_or_initialize_by_publication_date(pub_date)
      issue.special_filings_updated_at = parser.document.special_filings_updated_at
      issue.regular_filings_updated_at = parser.document.regular_filings_updated_at
      issue.save!

      new_documents = []
      parser.document.grouped_pi_documents.each do |attr|
        doc_importer = Content::PublicInspectionImporter.import(attr)
        issue.public_inspection_documents << doc_importer.document unless issue.public_inspection_document_ids.include?(doc_importer.document.id)
        new_documents << doc_importer.document if doc_importer.new_record?
      end
      issue.touch(:published_at) unless issue.published_at
      issue.touch(:updated_at)

      new_documents
    end

    def self.import(attributes)
      importer = new(attributes)
      importer.save!
      importer
    end

    def self.save_file(html)
      dir = FileUtils.mkdir_p("#{Rails.root}/data/public_inspection/html/#{Time.now.strftime('%Y/%m/%d')}/")
      f = File.new("#{dir.to_s}/#{Time.now.to_s(:HMS_Z)}.html", "w")
      f.write(html)
      f.close
    end

    def initialize(attributes)
      @pi = PublicInspectionDocument.find_or_initialize_by_document_number(attributes.delete(:document_number))
      @new_record = @pi.new_record?
      url = attributes.delete(:url)
      attributes.each_pair do |attr,val|
        send("#{attr}=", val)
      end
      self.url = url
    end

    def new_record?
      @new_record
    end

    def document
      @pi
    end

    def save!
      @pi.save!
    end

    delegate :document_number=, :granule_class=, :toc_subject=, :toc_doc=, :title=, :filed_at=, :publication_date=, :editorial_note=, :docket_numbers=, :to => :document

    def details=(val)
      docket_numbers = []
      val = val.sub(/^\[/,'').sub(/\]$/,'')

      # clear out the publication date so documents can be revoked
      self.publication_date = nil

      val.split(/\s*;\s*/).each do |part|
        case part
        when /Filed: (.+)/
          begin
            date = Time.zone.parse($1)
            self.filed_at = date 
          rescue
            # don't clear this out
          end
        when /Publication Date: (.+)/
          self.publication_date = $1
        else
          docket_numbers << part
        end
      end
      self.docket_numbers = docket_numbers.map{|number| DocketNumber.new(:number => number)}
    end

    def agency_names=(names)
      @pi.agency_names = names.map{|name| AgencyName.find_or_create_by_name(name)}
      @pi.agency_ids = @pi.agency_names.map(&:agency_id)
    end

    def url=(url)
      if url !~ /^http/
        url = "http://www.ofr.gov/" + url
      end

      if !ENV['SKIP_DOWNLOADS'] && (not_already_downloaded? || etag_from_head(url) != @pi.pdf_etag)
        pdf_path = File.join(Dir.tmpdir, File.basename(url))
        puts "downloading #{url}..."
        curl = Curl::Easy.download(url, pdf_path) {|c| c.follow_location = true}
        puts "done."

        headers = HttpHeaders.new(curl.header_str)

        if headers.response_code.to_i == 200
          @pi.raw_text = get_plain_text(pdf_path)
          @pi.pdf_etag = headers.etag
          @pi.pdf = File.new(pdf_path)
          @pi.num_pages = Stevedore::Pdf.new(pdf_path).num_pages
          File.delete(pdf_path)
        else
          puts "Unable to download #{url}: #{headers.response_code}"
        end
      end
    end

    def get_plain_text(pdf_path)
      raw_text = `pdftotext -enc UTF-8 #{pdf_path} -`
      raw_text.gsub!(/-{3,}/, '') # remove '----' etc
      raw_text.gsub!(/\.{4,}/, '') # remove '....' etc
      raw_text.gsub!(/_{2,}/, '') # remove '____' etc
      raw_text.gsub!(/\\\d+\\/, '') # remove '\16\' etc
      raw_text.gsub!(/\|/, '') # remove '|'
      raw_text.gsub!(/\n\d+\n\n/,"\n") # remove page numbers
      raw_text
    end

    def filing_type=(val)
      @pi.special_filing = val == 'special'
    end

    def not_already_downloaded?
      @pi.pdf.url == 'missing.pdf'
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
      attr_reader :pi_documents, :special_filings_updated_at, :regular_filings_updated_at
      def initialize(*args)
        @str = ''
        @pi_documents = []
        super
      end

      def grouped_pi_documents
        @pi_documents.group_by{|attr| attr[:document_number]}.map do |document_number, attrs|
          grouped = attrs.last.dup
          grouped.delete(:agency)
          grouped[:agency_names] = attrs.map{|attr| attr[:agency]}
          grouped
        end
      end

      def start_element(name, raw_attributes = [])
        if @str.present?
          handle_characters
          @str = ''
        end

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
        when 'b', 'strong'
          @context = :updated_at_or_agency_or_granule_class_or_editorial_note
        when 'a'
          if @context != :editorial_note
            # raise self.inspect if attributes['href'] == 'PI.pdf'
            if attributes['href'] && attributes['target']
              @url = attributes['href']
              @context = :details if attributes['href']
            elsif ['special', 'regular'].include?(attributes['name'])
              @filing_type = attributes['name']
            end
          end
        end
      end

      # SAX parsers don't guarantee that you get all of the characters at
      #   once, and in practice we're getting split apart at special
      #   character entities, so rather than doing the actual logic
      #   with the character callback, we're storing the accumulated
      #   characters and them processing them when the next element
      #   begins.
      def characters(str)
        @str += str.gsub(/\302\240/, ' ')
      end

      def handle_characters
        # normalize whitespace
        @str.gsub!(/\s+/, ' ')
        @str.strip!

        case @context
        when :updated_at_or_agency_or_granule_class_or_editorial_note
          if @str =~ /^EDITORIAL\s*NOTE:/i
            @pi_documents.last[:editorial_note] = @str.sub(/^EDITORIAL\s*NOTE:\s*/i,'')
            @context = :editorial_note
          elsif @str =~ /.*?(Special|Regular)\s*(?:.*?)\s*(?:updated\s+at|as\s+of)\s*(.*)/i
            updated_at = Time.zone.parse($2)
            case $1
            when 'Special'
              @special_filings_updated_at = updated_at
            when 'Regular'
              @regular_filings_updated_at = updated_at
            end
          else
            if GRANULE_CLASSES[@str]
              @granule_class = GRANULE_CLASSES[@str]
            else
              @agency = @str
            end
          end
        when :document_number_or_toc_doc
          if @document_number
            @toc_doc = @document_number
          end
          @document_number = @str
        when :editorial_note
          @pi_documents.last[:editorial_note] ||= ''
          @pi_documents.last[:editorial_note] += ' ' + @str
        when :continued_editorial_note
          @context = :editorial_note
        when :toc_subject
          @toc_subject = @str
          @toc_doc = nil
          @title = ''
        when :details
          @details = @str

          if @granule_class == 'PRESDOCU'
            # throw out the 'PROCLAMATION', etc for now
            @agency = 'Executive Office of the President'
          end

          if @toc_doc.blank? && @toc_subject.present?
            @title = @toc_subject.dup
            @toc_subject = nil
          end

          if @document_number
            @document_number.gsub!(/.*?([A-Za-z0-9-]+)$/, '\1')
            @pi_documents << {
              :filing_type     => @filing_type,
              :details         => @details,
              :agency          => @agency,
              :granule_class   => @granule_class,
              :document_number => @document_number,
              :toc_subject     => @toc_subject,
              :toc_doc         => @toc_doc,
              :title           => @title || '',
              :url             => @url
            }
          end
          @document_number = nil
        end
      end

    end
  end
end
