task :extract_dates => :environment do 
  Entry.all.each do |entry|
    puts "extracting dates for #{entry.document_number}"
    
    puts entry.abstract
    dates = []
    
    Entry.transaction do
      entry.referenced_dates = []
      Date.set_today(entry.publication_date.to_s(:db)) do
        PotentialDateExtractor.extract(entry.abstract).each do |potential_date|
          begin 
            date = Date.parse(potential_date)
          rescue ArgumentError => e
            if e.message == "invalid date"
              next
            else
              raise e
            end
          end
          
          context = entry.abstract.match(/\b.{0,100}#{Regexp.escape(potential_date)}.{0,100}\b/)[0]
          entry.referenced_dates.create(:date => date, :string => potential_date, :context => context, :prospective => date > entry.publication_date)
        end
      end
    end
    
  end
end