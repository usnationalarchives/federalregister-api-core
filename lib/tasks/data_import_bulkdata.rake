namespace :data do
  namespace :import do
    desc "Import entries bulkdata file(s) into the database"
    task :bulkdata => :environment do
      require 'ftools'
      require 'open-uri'
      
      date = ENV['DATE'].blank? ? Time.current.to_date.to_s(:db) : ENV['DATE']
      lax_mode = ENV['LAX'].blank? ? false : true

      url = 'https://www.gpo.gov/fdsys/bulkdata/FR/' + case date
          when /^\d{4}$/
            "#{date.gsub(/-/, '/')}/FR-#{date}.zip"
          when /^\d{4}-\d{2}$/
            "#{date.gsub(/-/, '/')}/FR-#{date}.zip"
          when /^\d{4}-\d{2}-\d{2}/
            "#{date.split(/-/)[0..1].join('/')}/FR-#{date}.xml"
          else
            raise "Invalid date; must be of the form 2009, 2009-12, 2009-12-31"
          end
      
      xml_files_to_process = []
      
      bulkdata_dir = "#{RAILS_ROOT}/data/bulkdata"
      file_path = "#{bulkdata_dir}/#{File.basename(url)}"
      if File.exists?(file_path)
        puts "skipping #{url}..."
      else
        puts "downloading #{url}..."
        
        open(url) do |input|
          open(file_path, "wb") do |output|
            while (buf = input.read(8192))
              output.write buf
            end
          end
        end
      end
      
      if file_path =~ /\.zip$/
        puts "extracting #{file_path}..."
        Zip::ZipFile.open(file_path).each do |file|
          path_to_extract_to = "#{bulkdata_dir}/#{File.basename(file.name)}"
          file.extract(path_to_extract_to) { puts "#{path_to_extract_to} already exists..."; true }
          xml_files_to_process << path_to_extract_to
        end
      else
        xml_files_to_process << file_path
      end
      
      xml_files_to_process.sort.each do |file|
        puts "importing #{file}..."
        doc = Nokogiri::XML(open(file))
      
        doc.css('RULE, PRORULE, NOTICE, PRESDOCU').each do |entry_node|
          raw_frdoc = entry_node.css('FRDOC').first.try(:content)
          
          if raw_frdoc.present?
            document_number = /FR Doc.\s*([^ ;]+)/i.match(raw_frdoc).try(:[], 1)
            if document_number.blank?
              puts "Document number not found for #{raw_frdoc}"
            end
          else
            puts "no FRDOC in #{entry_node.name} in #{file}"
          end
        
          entry = Entry.find_by_document_number(document_number)
          if entry.nil?
            if lax_mode
              raise ActiveRecord::RecordNotFound
            else
              puts "Document #{document_number} not found"
              next
            end
          end
        
          entry.full_xml = entry_node.to_s
          entry.save
        end
      end
    end
  end
end