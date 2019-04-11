namespace :content do
  namespace :graphics do
    task :extract => :environment do
      dates = Content.parse_dates(ENV["DATE"])
      dates.each do |date|
        extractor = Content::GraphicsExtractor.new(date)
        extractor.perform
      end
    end
  end
end