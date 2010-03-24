namespace :data do
  namespace :extract do
    task :graphics => :environment do
      require 'tmpdir'
      date = ENV['DATE_TO_IMPORT'] || Date.today
      
      if date =~ /^\d{4}$/
        dates = Entry.find_as_array(
          :select => "distinct(publication_date) AS publication_date",
          :conditions => {:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")},
          :order => "publication_date DESC"
        )
      else
        dates = [date]
      end
      
      dates.each do |date|
        entries = Entry.all(:conditions => {:publication_date => date}, :order => "entries.id")
        if entries.size > 0 && entries.all?(&:has_full_xml?)
          Dir.mktmpdir("entry_graphics") do |dir|
            # Download PDF of all entries for a given date
            pdf_file_loc = "#{dir}/entries.pdf"
            url = "http://www.gpo.gov:80/fdsys/pkg/FR-#{date}/pdf/FR-#{date}.pdf"
            Curl::Easy.download(url, pdf_file_loc)
          
            # Extract all graphics
            output = `pdfimages #{pdf_file_loc} #{dir}/extracted_graphic`
            extracted_graphics = Dir.glob("#{dir}/extracted_graphic*").sort
          
            entries.each do |entry|
              doc = Nokogiri::XML(open(entry.full_xml_file_path))
              graphic_ids = doc.css('GID').map{|node| node.content}
            
              graphic_ids.each do |identifier|
                extracted_graphic = extracted_graphics.shift
              
                graphic = Graphic.find_by_identifier(identifier)
                unless graphic
                  graphic = Graphic.new(:graphic => File.open(extracted_graphic), :identifier => identifier)
                end
              
                graphic.entries << entry unless graphic.entry_ids.include?(entry.id)
                graphic.save!
              end
            end
          end
        else
          puts "cannot process #{date}; all entries must have XML"
        end
      end
    end
  end
end