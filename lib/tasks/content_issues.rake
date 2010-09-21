namespace :content do
  namespace :issues do
    task :mark_complete do
      date = ENV['DATE'] || Time.local.to_date
      
      issue = Issue.find_by_publication_date(date) || Issue.new(:publication_date => date)
      issue.complete!
    end
  end
end