namespace :data do
  namespace :import do
    desc "Import regulation_id_number from MODS file(s)"
    task :regulation_id_number => :environment do
      Dir.glob("#{RAILS_ROOT}/data/mods/*.xml").sort.each do |file_name|
        puts "processing #{file_name}..."
        doc = Nokogiri::XML(open(file_name))
        doc.css('relatedItem').each do |entry_node|
          document_number = entry_node.css('accessId').first.try(:content)
          next if document_number.nil?
        
          entry = Entry.find_by_document_number(document_number)
          next if entry.nil?
          
          entry.regulation_id_number = entry_node.css('identifier[type="regulation ID number"]').first.try(:content)
          entry.save!
        end
      end
    end
  end
end