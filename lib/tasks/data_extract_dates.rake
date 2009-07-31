namespace :data do
  namespace :extract do
    desc "extract dates from entry text"
    task :dates => :environment do 
      Entry.all.each do |entry|
        puts "Extracting dates for #{entry.document_number}"
        
        puts entry.abstract
        dates = []
        
        Entry.transaction do
          ReferencedDate.delete_all(:entry_id => entry.id, :date_type => ["ExtractedPriorDate", "ExtractedFutureDate"])
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
              
              if date <= entry.publication_date
                date_type = "ExtractedPriorDate"
              else
                date_type = "ExtractedFutureDate"
              end
              
              entry.referenced_dates.create(:date => date, :string => potential_date, :context => context, :date_type => date_type)
            end
          end
        end
      end
    end
  end
end