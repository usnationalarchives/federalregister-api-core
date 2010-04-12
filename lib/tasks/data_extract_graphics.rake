namespace :content do
  namespace :graphics do
    task :extract => :environment do
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
        extractor = Content::GraphicsExtractor.new(date)
        extractor.perform
      end
    end
  end
end