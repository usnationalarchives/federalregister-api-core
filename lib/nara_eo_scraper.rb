require 'nokogiri'
require 'csv'
require 'open-uri'

class NaraEoScraper

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
    president_metadata.each do |metadata|
      metadata.year_specific_urls.each do |url|
        scrape_year_specific_page(url, metadata.president_identifier)
      end
    end
  end

  HEADERS = ['title', 'citation', 'presidential_document_number', 'signing_date', 'parsed_signing_date', 'publication_date', 'parsed_publication_date', 'president', 'disposition_notes', 'scraped_url']
  def self.replace_file_and_write_headers
    CSV.open('data/nara_executive_orders.csv', 'w', write_headers: true, headers: HEADERS) do |csv|
    end
  end

  # Use this to test individual scraping of pages: 
  def self.scrape_year_specific_page(url, president_identifier)
    # Load and parse the HTML file
    html_content = URI.open(url).read


    # Prepare CSV file
    CSV.open('data/nara_executive_orders.csv', 'a', write_headers: false, headers: HEADERS) do |csv|
      eo_metadata(html_content, president_identifier, url).each do |eo|
        csv << eo
      end
    end
  end

  def self.eo_metadata(html_content, president_identifier, url)
    # Iterate over each executive order
    nokogiri_doc = Nokogiri::HTML(html_content)
    nokogiri_doc.css('hr').map do |hr|
      title_element = hr.next_element
      next unless title_element && title_element.name == 'p' && (hr.next_element.children.length > 1)

      # Extract title
      title = title_element.text.strip.split("\n")
      title.shift
      title = title.join("\n").strip

      # Extract presidential document number from the title
      presidential_document_number = title_element.children.find{|x| x.name == 'a'}.try(:[], 'name') || title_element.children.first.text.gsub(/Executive Order /, '').strip

    
      # Initialize details
      details = { 'signing_date' => '', 'citation' => '', 'publication_date' => '', 'disposition_notes' => [] }

      # Iterate over details
      title_element.xpath('following-sibling::ul[1]/li').each do |li|
        case li.text.strip
        when /^Signed:/
          details['signing_date'] = li.text.gsub('Signed: ', '')
          details['parsed_signing_date'] = Date.try(:parse, details['signing_date'])
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
        when /Federal Register page and date:/i
          citation_text = li.text.gsub('Federal Register page and date: ', '').strip

          #Sometimes we have a citation like "Federal Register page and date: 61 FR 1209; January 18, 1996" and sometimes it's like "Federal Register page and date: 70 FR 2323, January 12, 2005"
          if citation_text.include?(";")
            details['citation'] = citation_text.split(';').first
            details['publication_date'] = citation_text.split(';').last
          else
            details['citation'] = citation_text.split(',').first
            details['publication_date'] = citation_text.split(',').last(2).join(',')
          end
          begin
            details['parsed_publication_date'] = Date.parse(details['publication_date'])
          rescue
            details['parsed_publication_date'] = "date_parsing_error"
          end
        else
          details['disposition_notes'] << li.text.strip
        end
      end

      # Concatenate disposition notes
      disposition_notes = details['disposition_notes'].join(', ')

      [
        title, details['citation'],
        presidential_document_number,
        details['signing_date'],
        details['parsed_signing_date'],
        details['publication_date'],
        details['parsed_publication_date'],
        president_identifier,
        disposition_notes,
        url
      ]
    end
  end

end
