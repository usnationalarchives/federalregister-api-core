namespace :content do
  namespace :entries do
    namespace :html do
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
    end
  end
end
