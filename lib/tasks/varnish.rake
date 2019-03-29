namespace :varnish do
  namespace :expire do
    desc "Expire everything from varnish"
    task :everything => :environment do
      include CacheUtils
      purge_cache(".*")
    end

    desc "Expire from varnish pages so that late notice can go up"
    task :pages_warning_of_late_content => :environment do
      if Issue.current_issue_is_late? && Rails.env.production?
        Mailer.deliver_admin_notification("Today's issue #{Time.current.to_date} on #{RAILS_ENV} is late. There may have been a problem!")

        include CacheUtils
        purge_cache("/")
        purge_cache("/documents/#{Time.current.to_date.strftime('%Y')}/#{Time.current.to_date.strftime('%m')}")
      end
    end
  end
end
