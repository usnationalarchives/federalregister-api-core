namespace :content do
  namespace :fr_index do
    desc "Update FR Index Needs Attention status cache"
    task :update_status_cache => :environment do
      year = ENV['YEAR'] || Issue.current.publication_date.year

      FrIndexPresenter.new(year).agencies.each do |agency_year|
        agency_year.update_cache
      end
    end
  end
end