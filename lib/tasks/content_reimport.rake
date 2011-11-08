namespace :content do
  namespace :entries do
    task :reimport => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(EntryReimporter, date, :all)
      end
    end
  end
end
