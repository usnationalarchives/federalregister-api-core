namespace :data do
  namespace :extract do
    desc "Call out to Open Calais to geocode locations in our entries"
    task :places => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])
      approximate_remaining_daily_api_limit = Settings.open_calais.daily_api_call_limit

      dates.each do |date|
        begin
          Entry.where("publication_date = ? AND abstract IS NOT NULL", date).find_each do |entry|
            puts "determining places for #{entry.document_number} (#{entry.publication_date})"

            next if entry.abstract.blank?
            Sidekiq::Client.enqueue(PlaceDeterminer, entry.id)
            approximate_remaining_daily_api_limit -= 1
          end
        rescue StandardError => e
          puts e.message
          puts e.backtrace.join("\n")
          Honeybadger.notify(e)
        end
      end

      PlaceDeterminerEnqueuer.new(approximate_remaining_daily_api_limit).perform
    end

    desc "Extract places for historical documents."
    task :places_for_historical_documents => :environment do
      # NOTE: Intended to run on days when an import does not occur so we can make use of our OpenCalais API quota
      PlaceDeterminerEnqueuer.new(Settings.open_calais.daily_api_call_limit).perform
    end
  end
end
