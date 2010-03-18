namespace :data do
  namespace :extract do
    task :graphics => :environment do
      require 'tmpdir'
      specified_date = ENV['DATE_TO_IMPORT']
      
      if specified_date && specified_date =~ /^\d{4}$/
        conditions = {:publication_date => Date.parse("#{specified_date}-01-01")..Date.parse("#{specified_date}-12-31")}
      else
        date = Date.parse(specified_date) || Date.parse(ENV['DATE_TO_IMPORT'])
        conditions = {:publication_date => date}
      end
      Entry.find_each(:conditions => conditions) do |entry|
        if entry.has_full_xml?
          puts "evaluating #{entry.document_number}"
          Dir.mktmpdir("entry_graphics") do |dir|
            doc = Nokogiri::XML(open(entry.full_xml_file_path))
            identifiers = doc.css('GID').map{|node| node.content}
            if identifiers.blank?
              puts "\tno graphics! skipping!"
              next
            end
            
            pdf_file_loc = "#{dir}/entry.pdf"
            url = entry.source_url(:pdf)
            puts "\tdownloading #{url}..."
            Curl::Easy.download(entry.source_url(:pdf), pdf_file_loc)
          
            puts "\textracting images from pdf..."
            output = `pdfimages #{pdf_file_loc} #{dir}/`
            Dir.glob("#{dir}/*.pbm").each_with_index do |extracted_file,i|
              identifier = identifiers[i]
              puts "\thandling #{identifier}..."
          
              graphic = Graphic.find_by_identifier(identifier)
              unless graphic
                converted_file_path = "#{dir}/#{i}.gif"
                `convert #{extracted_file} #{converted_file_path}`
                graphic = Graphic.new(:graphic => File.open(converted_file_path), :identifier => identifier)
              end
            
              graphic.entries << entry unless graphic.entry_ids.include?(entry.id)
            
              graphic.save!
            end
          end
        end
      end
    end
  end
end