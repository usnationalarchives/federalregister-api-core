namespace :content do
  namespace :entries do
    namespace :json do
      namespace :compile do
        desc "Compile json for table of contents"
        task :daily_toc => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling daily table of contents json for #{date}..."
            XmlTableOfContentsTransformer.perform(date)
          end
        end
      end
    end
  end
end
