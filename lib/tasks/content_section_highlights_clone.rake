namespace :content do
  namespace :section_highlights do
    desc "copy prior day's section assignments"
    task :clone => :environment do
      date = ENV['DATE_TO_IMPORT'] || Date.today
      
      Content::SectionHighlightCloner.new.clone(date)
    end
  end
end