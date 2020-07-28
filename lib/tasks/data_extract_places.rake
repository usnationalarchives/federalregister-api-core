namespace :data do
  namespace :extract do
    desc "Call out to Open Calais to geocode locations in our entries"
    task :places => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])

      dates.each do |date|
        begin
          Entry.where("publication_date = ? AND abstract IS NOT NULL", date).find_each do |entry|
            puts "determining places for #{entry.document_number} (#{entry.publication_date})"
            # previous_date = nil

            next if entry.abstract.blank?
            Sidekiq::Client.enqueue(PlaceDeterminer, entry.id)
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
