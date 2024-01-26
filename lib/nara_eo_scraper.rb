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
  PRESIDENT_INDEX_PATHS = %w(
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
  def self.presidential_page_objects
    PRESIDENT_INDEX_PATHS.map do |path|
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

    MANUAL_ATTRIBUTE_CHANGES.
      select{|eo_number, attr| attr['manual_addition']}.
      to_h.
      values.
      each do |attrs|
        results << attrs.values
      end

    # Sort results by EO number
    CSV.open('data/nara_executive_orders.csv', 'a', write_headers: false, headers: HEADERS) do |csv|
      results.sort_by{|eo_metadata| eo_metadata[0].to_i}.each do |eo_metadata|
        csv << eo_metadata
      end
    end
  end

  def self.save_nara_pages_to_disk
    base_directory = Rails.root.join('data', "nara_pages_archive_#{Date.current.to_s(:iso)}/")

    urls = ["#{BASE_URL}/federal-register/executive-orders/disposition"]
    PRESIDENT_INDEX_PATHS.each do |path|
      urls << "#{BASE_URL}#{path}"
    end
    president_metadata.each do |metadata|
      metadata.year_specific_urls.each do |url|
        urls << url
      end
    end
    urls

    urls.each do |url|
      html_content = URI.open(url).read
      #Replace external URLs with local refs
      html_content = html_content.gsub("#{BASE_URL}/federal-register/executive-orders/", "")
      html_content = html_content.gsub("/federal-register/executive-orders/", "")
      path_sans_host = url.gsub("#{BASE_URL}/federal-register/executive-orders/","")
      path_on_disk = "#{base_directory}#{path_sans_host}"
      FileUtils.mkdir_p(File.dirname(path_on_disk))
      puts path_on_disk
      File.write(path_on_disk, html_content)
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
      next unless title_element && title_element.name == 'p' && (title_element.children.length > 1)

      # Extract title
      title = title_element.text.strip.split("\n")
      if title[0].strip == 'Executive Order' 
        #Handle some Kennedy/Carter-era EOs where a newline separates the string 'Executive Order' and the EO number
        title = [title[0] + title[1]] + title[2..-1]
      end

      title.shift
      title = title.join("\n").strip

      eo_number = anchor_el_with_name['name']
      title = title.
        gsub('\n','').
        tap do |string|
          if eo_number.present?
            string.gsub!(/^\s*#{eo_number}\s*/,"") # eg remove whitespace EO number and succeeding preceding whitespace: '12334\n\n \n \n Example Title'
          end
        end

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
        when /not received for Federal Register publication/i
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_for_publication'
          end
        when /not published/i
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_for_publication'
          end
        when /(?<!\()\bnot published\b(?!\))/i #eg EO 10995 mentions '(not published)' with reference to a different EO
          # mark columns as inappropriate
          ['citation', 'publication_date', 'parsed_publication_date'].each do |column_name|
            details[column_name] = 'not_received_for_publication'
          end
        when /not received in time for publication/i
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
          elsif citation_text.first.match?(/[[:alpha:]]/) || citation_text.ends_with?(',') 
            matches = citation_text.match(/^(.*?\d{4})(.*$)/)
            next if matches.nil?

            publication_date = matches[1]
            citation = matches[1].try(:chomp,',')
            details['publication_date'] = publication_date
            details['citation'] = citation = matches[2].gsub(',',"").try(:strip)
          elsif citation_text.count(",") == 1 # eg Federal Register Page and Date: 13 FR 27 January 3, 1948
            matches = citation_text.match(/(\d+ FR \d+)\s+(.+)/)
            next if matches.nil?
            citation = matches[1]
            publication_date = matches[2]
            details['citation'] = citation
            details['publication_date'] = publication_date
          else
            details['citation'] = citation_text.split(',').first.gsub(NON_BREAKING_SPACE_REGEX,"").strip
            details['publication_date'] = citation_text.split(',').last(2).join(',')
          end
          begin
            details['parsed_publication_date'] = Date.parse(details['publication_date']).try(:to_s, :iso)
          rescue
            details['parsed_publication_date'] = "date_parsing_error"
          end
        else
          details['disposition_notes'] << li.text.strip.gsub("\n","")
        end
      end

      # Concatenate disposition notes
      disposition_notes = details['disposition_notes'].
        join('\n').
        gsub(NON_BREAKING_SPACE_REGEX,"")


      attributes = {
          'executive_order_number' => presidential_document_number,
          'title'                  => title,
          'citation'               => details['citation'],
          'signing_date_string'    => details['signing_date'],
          'signing_date'           => details['parsed_signing_date'],
          'publication_date_string'=> details['publication_date'],
          'publication_date'       => details['parsed_publication_date'],
          'president'              => NARA_IDENTIFIER_MAPPING[president_identifier],
          'disposition_notes'      => disposition_notes,
        'scraped_url'              => url,
      }.tap do |attrs|
        manual_changes = MANUAL_ATTRIBUTE_CHANGES[presidential_document_number]
        if manual_changes
          attrs.merge!(manual_changes)
        end
      end
      
      attributes.values
    end
  end


  MANUAL_ATTRIBUTE_CHANGES = {
    '7729' => {'publication_date' => '1937-10-20'},
    '7925' => {'publication_date' => '1938-07-07'},
    '8467' => {'publication_date' => '1940-07-04'},
    '8596' => {'publication_date' => '1940-11-20'},
    '8869' => {'publication_date' => '1931-08-26'},
    '8874' => {'signing_date' => '1941-08-28', 'publication_date' => '1941-08-30'},
    '8921' => {'publication_date' => '1941-10-25'},
    '9312' => {'publication_date' => '1943-03-12'},
    '9670' => {'publication_date' => '1946-01-01'},
    '9787' => {'signing_date' => '1946-10-05'},
    '9959' => {'publication_date' => '1948-05-20'},
    '10010' => {'publication_date' => '1948-10-19'},
    '10092' => {'publication_date' => '1949-12-22'},
    '10101' => {'signing_date' => '1950-01-31'},
    '10151' => {'publication_date' => '1950-08-15'},
    '10681' => {'signing_date' => '1956-10-22'},
    '10932' => {'signing_date' => '1961-04-07', 'publication_date' => '1961-04-11'},
    '11026' => {'publication_date' => '1962-06-12'},
    '11304' => {'publication_date' => '1966-09-14'},
    '11838' => {'publication_date' => '1975-02-07'},
    '12458' => {'publication_date' => '1984-01-17'},
    '12825' => {'citation' => '32 FR 10049'},
    '12287' => {
      'executive_order_number' => 12287,
      'title'                  => 'Decontrol of crude oil and refined petroleum products',
      'citation'               => '46 FR 9909',
      'signing_date_string'    => nil,
      'signing_date'           => '1981-01-28',
      'publication_date_string'=> nil,
      'publication_date'       => '1981-01-30',
      'president'              => 'ronald-reagan',
      'disposition_notes'      => nil,
      'scraped_url'            => 'https://www.archives.gov/federal-register/executive-orders/1981-reagan.html',
      'manual_addition'        => true,
    },
    '12400' => {
      'executive_order_number' => 12400,
      'title'                  => "President's Commission on Strategic Forces",
      'citation'               => "48 FR 381",
      'signing_date_string'    => nil,
      'signing_date'           => "1983-01-03",
      'publication_date_string'=> nil,
      'publication_date'       => "1983-01-05",
      'president'              => 'ronald-reagan',
      'disposition_notes'      => "Amended by: EO 12406, February 18, 1983; EO 12424, June 10, 1983\nRevoked by: EO 12534, September 30, 1985",
      'scraped_url'            => "https://www.archives.gov/federal-register/executive-orders/1983.html",
      'manual_addition'        => true,
    },
    '12498' => {
      'executive_order_number' => 12498,
      'title'                  => "Regulatory planning process",
      'citation'               => "50 FR 1036",
      'signing_date_string'    => nil,
      'signing_date'           => "1985-01-04",
      'publication_date_string'=> nil,
      'publication_date'       => "1985-01-08",
      'president'              => 'ronald-reagan',
      'disposition_notes'      => "Revoked by: EO 12866, September 30, 1993\nSee: EO 12291, February 17, 1981; EO 12612, October 26, 1987; President's Message to Congress, November 5, 1991 (Weekly Compilation of Presidential Documents, v. 27, no. 45); EO 12803, April 30, 1992",
      'scraped_url'            => "https://www.archives.gov/federal-register/executive-orders/1985.html",
      'manual_addition'        => true,
    },
    '12543' => {
      'executive_order_number' => '12543',
      'title'                  => 'Prohibiting trade and certain transactions involving Libya',
      'citation'               => '51 FR 875',
      'signing_date_string'    => nil,
      'signing_date'           => '1986-01-07',
      'publication_date_string'=> nil,
      'publication_date'       => '1986-01-09',
      'president'              => 'ronald-reagan',
      'disposition_notes'      => "See: Department of the Treasury regulations, 51 FR 1354; Department of Commerce regulations, 51 FR 2353; EO 12544, January 8, 1986; Notice of December 23, 1986; Notice of December 15, 1987; Notice of December 28, 1988; Notice of January 4, 1990; Notice of January 2, 1991; Notice of December 26, 1991; EO 12801, April 15, 1992; Notice of December 14, 1992; Notice of December 2, 1993; Notice of December 22, 1994; Notice of January 3, 1996; Notice of January 2, 1997; Notice of January 2, 1998; Notice of December 30, 1998; Notice of December 29, 1999; Notice of January 4, 2001; Notice of January 3, 2002; Notice of January 2, 2003; Notice of January 5, 2004\nRevoked by: EO 13357, September 20, 2004",
      'scraped_url'            => "https://www.archives.gov/federal-register/executive-orders/1986.html",
      'manual_addition'        => true,
    },
    '12623' => {
      'executive_order_number' => '12623',
      'title'                  => 'Delegating authority to implement assistance to the Nicaraguan Democratic Resistance',
      'citation'               => '53 FR 487',
      'signing_date_string'    => nil,
      'signing_date'           => '1988-01-06',
      'publication_date_string'=> nil,
      'publication_date'       => '1988-01-08',
      'president'              => 'ronald-reagan',
      'disposition_notes'      => nil,
      'scraped_url'            => "https://www.archives.gov/federal-register/executive-orders/1988.html",
      'manual_addition'        => true,
    },
    '12663' => {
      'executive_order_number' => 12663,
      'title'                  => "Adjustments of certain rates of pay and allowances",
      'citation'               => "54 FR 791",
      'signing_date_string'    => nil,
      'signing_date'           => "1989-01-06",
      'publication_date_string'=> nil,
      'publication_date'       => "1989-01-10",
      'president'              => 'ronald-reagan',
      'disposition_notes'      => "Supersedes: EO 12622, December 31, 1987\nSuperseded by: EO 12698, December 23, 1989",
      'scraped_url'            => "https://www.archives.gov/federal-register/executive-orders/1989-reagan.html",
      'manual_addition'        => true,
    },
  }

end
