namespace :content do
  namespace :audit do
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