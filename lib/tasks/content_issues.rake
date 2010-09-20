namespace :content do
  namespace :issues do
    task :mark_complete do
      date = ENV['DATE'] || Date.today
      
      issue = Issue.find_by_publication_date(date) || Issue.new(:publication_date => date)
      issue.complete!
    end
  end
end