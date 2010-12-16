namespace :content do
  namespace :audit do
    namespace :entries do
      desc "List dates without valid MODS files"
      task :missing_mods_files => :environment do
        (Date.parse('1994-01-01')..Date.today).each do |date|
          if Issue.should_have_an_issue?(date)
            if Entry.published_on(date).count == 0
              mods_file = Content::EntryImporter::ModsFile.new(date)
              File.delete(mods_file.file_path) if File.exists?(mods_file.file_path)
              begin
                mods_file.document
                puts "#{date}\tMODS file found on server, not here before"
              rescue Content::EntryImporter::ModsFile::DownloadError
                puts "#{date}\tNo MODS file"
              end
              
            end
          end
        end
      end
      
      desc "List pages with no title"
      task :title => :environment do
        Entry.find_each(:conditions => "title IS NULL or title = ''") do |entry|
          puts "#{entry.publication_date}\t#{entry.document_number}"
          
          if ENV['verbose']
            puts "\t#{entry.source_url('mods')}"
          end
          
          if ENV['confirm']
            importer = Content::EntryImporter.new(:entry => entry)
            title = importer.title
            if title.present?
              puts "BUT TITLE IS PRESENT IN MODS: '#{title}"
            end
            
            # if ENV['verbose']
            #   puts importer.mods_node
            # end
          end
        end
      end
      
      desc "List document numbers found in the bulkdata but missing in the MODS"
      task :missing_document_numbers_in_mods => :environment do
        Content.parse_dates(ENV['DATE']).each do |date|
          puts "checking #{date}" if ENV['VERBOSE']
          mods_document_numbers = Content::EntryImporter::ModsFile.new(date).document_numbers
          bulkdata_document_numbers = Content::EntryImporter::BulkdataFile.new(date).document_numbers
          (bulkdata_document_numbers - mods_document_numbers).each do |missing_document_number|
            puts "#{date}\t#{missing_document_number} not found in mods.xml"
          end
        end
      end
    end
    
    namespace :pages do
      # desc "List pages that are out of order"
      # task :out_of_order do
      #   
      # end
      
      desc "List pages that are missing; assumes correct order"
      task :missing => :environment do
        include EntryHelper
        (75..75).each do |volume|
          prior_end_page = 0
          prior_entry = nil
          year = volume + 1935
        
          Issue.all(:conditions => {:publication_date => Date.parse("#{year}-01-01") .. Date.parse("#{year}-12-31")}).each do |issue|
            issue.entries.scoped(:order => "entries.start_page, entries.id").each do |entry|
              num_missing_pages = (entry.start_page - prior_end_page) - 1
              if num_missing_pages > 3
                puts "#{prior_entry.try(:publication_date)} - #{entry.publication_date}:\t(#{volume} FR #{prior_end_page + 1});\tnum_missing: #{num_missing_pages}"
              
                if ENV['verbose']
                  ((prior_end_page + 1) .. (entry.start_page - 1)).each do |page|
                    puts "\thttp://www.gpo.gov/fdsys/search/citation.result.FR.action?federalRegister.volume=#{year}&federalRegister.page=#{page}&publication=FR"
                  end
                  if prior_entry
                    puts "\tprior: #{prior_entry.document_number}; date: #{prior_entry.publication_date}; pages: #{prior_entry.start_page}-#{prior_entry.end_page}"
                    puts "\t\t#{issue_pdf_url(prior_entry.publication_date)}"
                    puts "\t\t#{prior_entry.source_url(:mods)}"
                    puts "\t\thttp://www.gpo.gov/fdsys/search/getfrtoc.action?selectedDate=#{prior_entry.publication_date.to_s(:db)}"
                  end
                  
                  puts "\tcur: #{entry.document_number}; date: #{entry.publication_date}; pages: #{entry.start_page}-#{entry.end_page}"
                  puts "\t\t#{issue_pdf_url(entry.publication_date)}"
                  puts "\t\t#{entry.source_url(:mods)}"
                  puts "\t\thttp://www.gpo.gov/fdsys/search/getfrtoc.action?selectedDate=#{entry.publication_date.to_s(:db)}"
                end
              end
          
              prior_entry = entry
              prior_end_page = prior_entry.end_page
            end
          end
        end
      end
    end
    
    task :bulkdata => :environment do
      FCSV do |csv|
        elements = %w(AGENCY CFR RIN SUBJECT AGY ACT SUM)
        csv << ['Publication Date', 'Document Number'] + elements
        Entry.find_as_array(:select => "distinct(publication_date) AS publication_date",
                            :conditions => "publication_date IS NOT NULL",
                            :order => "publication_date DESC").each do |publication_date|
          entries = Entry.published_on(publication_date)
          entries.each do |entry|
            path = entry.full_xml_file_path
            if File.exists?(path)
              doc = Nokogiri::XML(open(path))
              row = [entry.publication_date, entry.document_number]
              elements.each do |elem|
                row << doc.css(elem).first.try(:to_s).try(:size)
              end
              csv << row
            end
          end
        end
      end
    end
  end
end