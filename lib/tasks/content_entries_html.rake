namespace :content do
  namespace :entries do
    namespace :html do
      # called by the daily importer
      namespace :compile do
        desc "Compile all HTML for entries"
        task :all => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling all html for #{date}..."
            date = date.is_a?(String) ? date : date.to_s(:iso)
            Content::EntryCompiler.perform(date)
          end
        end
      end

      # bulk reprocessing
      namespace :recompile do
        desc "Recompile all HTML for entries as background jobs"
        task :all => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "enqueuing job to compile all html for #{date}..."
            date = date.is_a?(String) ? date : date.to_s(:iso)
            Resque.enqueue Content::EntryCompiler, date
          end
        end
      end
    end
  end
end
