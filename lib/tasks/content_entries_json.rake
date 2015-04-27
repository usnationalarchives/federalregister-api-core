namespace :content do
  namespace :entries do
    namespace :json do
      namespace :compile do
        desc "Compile json for table of contents"
        task :all => %w(
                  daily_toc
                  fr_index
                )

        task :daily_toc => :environment do
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling daily table of contents json for #{date}..."
            XmlTableOfContentsTransformer.perform(date)
          end
        end

        task :fr_index => :environment do
          #BC TODO: Optimize if multiple dates passed in so index data not unnecessarily re-processed.
          dates = Content.parse_dates(ENV['DATE'])

          dates.each do |date|
            puts "compiling fr_index json for #{date}..."
            IndexCompiler.perform(date)
          end
        end

      end
    end
  end
end
