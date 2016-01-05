module Content
  class DispositionTableImporter
    def initialize(year_and_president, options = {})
      @year_and_president = year_and_president
      @options = options
    end

    def download_if_necessary!
      unless @options[:force_download] || File.exists?(file_path)
        FileUtils.mkdir_p(File.dirname(file_path))
        FederalRegisterFileRetriever.download(url, file_path)
      end
    end

    def file_path
      @file_path ||= File.join(Rails.root, 'data', 'disposition_tables', Date.current.to_s(:iso), "#{@year_and_president}.html")
    end

    def url
      @url ||= "http://www.archives.gov/federal-register/executive-orders/#{@year_and_president}.html"
    end

    def import
      download_if_necessary!
      parser = PageParser.new(file_path)
      parser.executive_orders.each do |executive_order|
        executive_order.persist!
      end
    end

    class PageParser
      def initialize(file_path)
        @doc = Nokogiri::HTML(File.open(file_path))
      end

      def executive_orders
        @doc.css('div#content hr + p').map do |p_node|
          attributes = {}

          attributes[:number] = p_node.children.first['name']
          p_node.xpath('following-sibling::ul[1]/li').each do |li_node|
            key, value = li_node.text().split(/\s*:\s*/,2)
            case key
            when 'Signed'
              val = value.gsub(/[^A-Za-z0-9 ,]/,'').strip
              attributes[:signing_date] = Date.strptime(val, "%B %d, %Y")
            when 'Federal Register page and date'
              attributes[:fr_volume], attributes[:fr_page] = value.match(/^(\d+) FR (\d+)/)[1,2]
            end
          end
          ExecutiveOrder.new(attributes)
        end
      end
    end

    class ExecutiveOrder < Struct.new(:number, :fr_volume, :fr_page, :signing_date)
      def initialize(attributes = {})
        attributes.each do |key, value|
          self[key] = value
        end
      end

      def persist!
        entries = Entry.find_all_by_volume_and_start_page(fr_volume, fr_page)
        if entries.size == 1
          entry = entries.first
          puts "updating EO #{number} -- #{entry.document_number} #{entry.publication_date}"
          entry.granule_class = 'PRESDOCU'
          entry.presidential_document_type = PresidentialDocumentType::EXECUTIVE_ORDER
          entry.executive_order_number = number
          entry.signing_date = signing_date
          entry.save
        else
          puts "couldn't find single document for EO #{number} (#{fr_volume} FR #{fr_page}): #{entries.map(&:document_number).inspect}"
        end
      end
    end
  end
end
