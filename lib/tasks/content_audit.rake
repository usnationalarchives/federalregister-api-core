namespace :content do
  namespace :audit do
    task :bulkdata => :environment do
      FCSV do |csv|
        elements = %w(AGENCY CFR RIN SUBJECT AGY ACT SUM)
        csv << ['Publication Date', 'Document Number'] + elements
        Issue.all(:order => "publication_date DESC").each do |issue|
          issue.entries.each do |entry|
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