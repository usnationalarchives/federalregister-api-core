namespace :notifications do
  namespace :content do
    desc "Triggers pager duty if content is late"
    task :late => :environment do
      if Issue.current_issue_is_late?("8AM") && Rails.env.production?
        Mailer.pager_duty("FR content is late!").deliver_now
      end
    end
  end
end
