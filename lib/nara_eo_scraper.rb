require 'nokogiri'
require 'csv'
require 'open-uri'

class NaraEoScraper

  NARA_IDENTIFIER_MAPPING = ActiveSupport::HashWithIndifferentAccess.new(
    obama: 'barack-obama',
    wbush: 'george-w-bush',
    clinton: 'william-j-clinton',
    bush: 'george-h-w-bush',
    reagan: 'ronald-reagan',
    carter: 'jimmy-carter',
    ford: 'gerald-ford',
    nixon: 'richard-nixon',
    johnson: 'lyndon-b-johnson',
    kennedy: 'john-f-kennedy',
    eisenhower: 'dwight-d-eisenhower',
    truman: 'harry-s-truman',
    roosevelt: 'franklin-d-roosevelt',
  )

  BASE_URL = "https://www.archives.gov"
  def self.presidential_page_objects
    paths = %w(
    /federal-register/executive-orders/obama.html
    /federal-register/executive-orders/wbush.html
    /federal-register/executive-orders/clinton.html
    /federal-register/executive-orders/bush.html
    /federal-register/executive-orders/reagan.html
    /federal-register/executive-orders/carter.html
    /federal-register/executive-orders/ford.html
    /federal-register/executive-orders/nixon.html
    /federal-register/executive-orders/johnson.html
    /federal-register/executive-orders/kennedy.html
    /federal-register/executive-orders/eisenhower.html
    /federal-register/executive-orders/truman.html
    /federal-register/executive-orders/roosevelt.html
    )
    paths.map do |path|
      OpenStruct.new(
        url: "#{BASE_URL}#{path}",
        president_identifier: path.split('/').last.gsub(".html","")
      )
    end
  end

  def self.president_metadata
    objects_to_decorate = presidential_page_objects
    objects_to_decorate.each do |page_object|
      html_content = URI.open(page_object.url).read
      doc = Nokogiri::HTML(html_content)

      # Extracting all URLs within the block-system-main section
      year_specific_urls = doc.css('#block-system-main ul li a').
        select do |link|
          link.children.text != "Subject\n Index"
        end.
        map do |link|
          "#{BASE_URL}#{link['href']}"
        end
      page_object.year_specific_urls = year_specific_urls
    end
    objects_to_decorate
  end

  def self.perform
    replace_file_and_write_headers
    results = []
    president_metadata.each do |metadata|
      metadata.year_specific_urls.each do |url|
        scrape_year_specific_page(url, metadata.president_identifier).each do |result|
          results << result
        end
      end
    end

    # Sort results by EO number
    CSV.open('data/nara_executive_orders.csv', 'a', write_headers: false, headers: HEADERS) do |csv|
      results.sort_by{|eo_metadata| eo_metadata[0].to_i}.each do |eo_metadata|
        csv << eo_metadata
      end
    end
  end

  HEADERS = ['executive_order_number', 'title', 'citation', 'signing_date_string', 'signing_date', 'publication_date_string', 'publication_date', 'president', 'disposition_notes', 'scraped_url']
  def self.replace_file_and_write_headers
    CSV.open('data/nara_executive_orders.csv', 'w', write_headers: true, headers: HEADERS) do |csv|
    end
  end

  # Use this to test individual scraping of pages: 
  def self.scrape_year_specific_page(url, president_identifier)
    # Load and parse the HTML file
    html_content = URI.open(url).read

    eo_metadata(html_content, president_identifier, url).each_with_object(Array.new) do |eo, results|
      if eo.present?
        puts eo
        results << eo
      end
    end
  end

  NON_BREAKING_SPACE_REGEX = /\u00A0/
  def self.eo_metadata(html_content, president_identifier, url)
    # Iterate over each executive order
    nokogiri_doc = Nokogiri::HTML(html_content)
    nokogiri_doc.css('p a[name]').map do |anchor_el_with_name|
      title_element = anchor_el_with_name.ancestors('p').first
    # nokogiri_doc.css('hr').map do |hr|
      # title_element = hr.next_element
      next unless title_element && title_element.name == 'p' && (title_element.children.length > 1)

      # Extract title
      title = title_element.text.strip.split("\n")
      if title[0].strip == 'Executive Order' 
        #Handle some Kennedy/Carter-era EOs where a newline separates the string 'Executive Order' and the EO number
        title = [title[0] + title[1]] + title[2..-1]
      end

      title.shift
      title = title.join("\n").strip

      # Extract presidential document number from the title
      presidential_document_number = title_element.children.first.text.gsub(/Executive Order /, '').gsub('No.','').strip
      if presidential_document_number.blank?
        presidential_document_number = title_element.css('a[name]').first.try(:[], 'name').try(:gsub, /^0.1_/,"")
      end
    
      # Initialize details
      details = { 'signing_date' => '', 'citation' => '', 'publication_date' => '', 'disposition_notes' => [] }

      # Iterate over details
      title_element.xpath('following-sibling::ul[1]/li').each do |li|
        case li.text.strip
        when /^Signed:/
          details['signing_date'] = li.text.gsub('Signed: ', '')
          details['parsed_signing_date'] = Date.try(:parse, details['signing_date']).try(:to_s, :iso)
        when /not received for Federal Register publication/
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_for_publication'
          end
        when /not received for publication/
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_for_publication'
          end
        when /not received in time for publication/
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_in_time_for_publication'
          end
        when /Federal Register page and date:/i, /\A\d+\sFR\s\d+/
          citation_text = li.text.gsub(/Federal Register page and date: /i, '').strip
          if citation_text.blank?
            # eg 10026-A is missing an FR page and date and just says 'Federal Register page and date:'
            details['citation'] = "no_citation_provided"
            next
          end

          #Sometimes we have a citation like "Federal Register page and date: 61 FR 1209; January 18, 1996" and sometimes it's like "Federal Register page and date: 70 FR 2323, January 12, 2005"
          if citation_text.include?(";")
            details['citation'] = citation_text.split(';').first.gsub(NON_BREAKING_SPACE_REGEX,"").strip
            details['publication_date'] = citation_text.split(';').last
          elsif citation_text.ends_with?(',')
            matches = citation_text.match(/^(.*?\d{4})(.*$)/)
            publication_date = matches[1]
            citation = matches[1].try(:chomp,',')
            details['publication_date'] = publication_date
            details['citation'] = citation = matches[2].try(:chomp,',').try(:strip)
          else
            details['citation'] = citation_text.split(',').first.gsub(NON_BREAKING_SPACE_REGEX,"").strip
            details['publication_date'] = citation_text.split(',').last(2).join(',')
          end
          begin
            details['parsed_publication_date'] = Date.parse(details['publication_date']).try(:to_s, :iso)
          rescue
            details['parsed_publication_date'] = "date_parsing_error"
          end
        when /\A\d+\sFR\s\d+\z/

        else
          details['disposition_notes'] << li.text.strip
        end
      end

      # Concatenate disposition notes
      disposition_notes = details['disposition_notes'].join(', ').gsub(NON_BREAKING_SPACE_REGEX,"").strip

      [
        presidential_document_number,
        title,
        details['citation'],
        details['signing_date'],
        details['parsed_signing_date'],
        details['publication_date'],
        details['parsed_publication_date'],
        NARA_IDENTIFIER_MAPPING[president_identifier],
        disposition_notes,
        url
      ]
    end
  end

end
