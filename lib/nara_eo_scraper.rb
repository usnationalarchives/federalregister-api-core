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

  HEADERS = ['title', 'citation', 'presidential_document_number', 'signing_date', 'publication_date', 'president', 'disposition_notes', 'scraped_url']
  def self.replace_file_and_write_headers
    CSV.open('data/nara_executive_orders.csv', 'w', write_headers: true, headers: HEADERS) do |csv|
    end
  end

  # Use this to test individual scraping of pages: 
  # reload!; NaraEoScraper.scrape_year_specific_page('https://www.archives.gov/federal-register/executive-orders/1998.html','clinton')
  def self.scrape_year_specific_page(url, president_identifier)
    # Load and parse the HTML file
    html_content = URI.open(url).read

    doc = Nokogiri::HTML(html_content)

    # Prepare CSV file
    CSV.open('data/nara_executive_orders.csv', 'a', write_headers: false, headers: HEADERS) do |csv|
      # Iterate over each executive order
      doc.css('hr').each do |hr|

        title_element = hr.next_element
        next unless title_element && title_element.name == 'p' && (hr.next_element.children.length > 1)

        # Extract title
        title = title_element.text.strip.split("\n").last.strip

        # Extract presidential document number from the title
        begin
          presidential_document_number = title_element.children.find{|x| x.name == 'a'}['name']
        rescue
          #eg Some truman documents
          presidential_document_number = title_element.children.first.text.gsub(/\D/, '')
        end
        # Initialize details
        details = { 'signing_date' => '', 'citation' => '', 'publication_date' => '', 'disposition_notes' => [] }

        # Iterate over details
        binding.pry if presidential_document_number == '13078'
        title_element.xpath('following-sibling::ul[1]/li').each do |li|
          case li.text.strip
          when /^Signed:/
            details['signing_date'] = li.text.gsub('Signed: ', '')
          when /^Federal Register page and date:/i
            citation_text = li.text.gsub('Federal Register page and date: ', '')
            details['citation'] = citation_text.split(',').first
            # binding.pry if details['citation'] == "75 FR 2053"
            details['publication_date'] = citation_text.split(',').last(2).join
          else
            details['disposition_notes'] << li.text.strip
          end
        end

        # Concatenate disposition notes
        disposition_notes = details['disposition_notes'].join(', ')

        # President is not available in the provided HTML structure
        president = president_identifier

        # Write to CSV
        csv << [title, details['citation'], presidential_document_number, details['signing_date'], details['publication_date'], president, disposition_notes, url]
      end
    end
  end

end
