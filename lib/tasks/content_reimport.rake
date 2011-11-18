namespace :content do
  namespace :entries do
    task :reimport => :environment do
      Content.parse_dates(ENV['DATE']).each do |date|
        Resque.enqueue(EntryReimporter, date,
                       :except => [:checked_regulationsdotgov_at, :regulationsdotgov_url, :comment_url],
                       :force_reload_mods => true,
                       :force_reload_bulkdata => true)
      end
    end
  end
end
