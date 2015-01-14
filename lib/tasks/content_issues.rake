namespace :content do
  namespace :issues do
    task :mark_complete => :environment do
      date = ENV['DATE'] || Time.current.to_date

      if Entry.published_on(date).count > 0
        issue = Issue.find_by_publication_date(date) || Issue.new(:publication_date => date)
        issue.complete!
      else
        puts "No entries in this issue; not marking as complete"
      end
    end
  end
end