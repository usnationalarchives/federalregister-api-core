namespace :data do
  namespace :extract do
    desc "Call out to Open Calais to geocode locations in our entries"
    task :places => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])

      dates.each do |date|
        begin
          Entry.find_each(:conditions => ["publication_date = ? AND abstract IS NOT NULL", date]) do |entry|
            puts "determining places for #{entry.document_number} (#{entry.publication_date})"
            # previous_date = nil

            next if entry.abstract.blank?
            Resque.enqueue(PlaceDeterminer, entry.id)
          end
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e)
        end
      end
    end
  end
end
