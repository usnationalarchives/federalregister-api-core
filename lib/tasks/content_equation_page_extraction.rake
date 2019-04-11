namespace :content do
  namespace :entries do
    desc "Rasterize PDF pages with equations in them"
    task :extract_equation_pages => :environment do
      dates = Content.parse_dates(ENV['DATE'])
      dates.each do |date|
        puts "extracting equation pages for #{date}"
        Content::EquationPageExtractor.new(date).perform
      end
    end
  end
end
