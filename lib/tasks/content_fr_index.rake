namespace :content do
  namespace :fr_index do
    desc "Update FR Index Needs Attention status cache"
    task :update_status_cache => :environment do
      begin
        year = ENV['YEAR'] || Issue.current.publication_date.year
        FrIndexAgencyStatusObserver.disabled = true

        FrIndexPresenter.new(year).agencies.each do |agency_year|
          agency_year.update_cache
        end
        FrIndexAgencyStatusObserver.disabled = false
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
        FrIndexAgencyStatusObserver.disabled = false
      end
    end
  end
end
