namespace :content do
  namespace :section_assignments do
    desc "copy prior day's section assignments"
    task :clone => :environment do
      date = ENV['DATE_TO_IMPORT'] || Date.today
      
      Content::SectionAssignmentCloner.new.clone(date)
    end
  end
end