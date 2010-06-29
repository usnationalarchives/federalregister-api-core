namespace :data do
  namespace :extract do
    desc "Scrape regulations.gov for id, comment URL"
    task :regulationsdotgov_id => :environment do
      date = ENV['DATE_TO_IMPORT'].blank? ? Date.today : Date.parse(ENV['DATE_TO_IMPORT'])
    end
  end
end