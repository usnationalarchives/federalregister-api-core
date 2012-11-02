namespace :mailing_lists do
  namespace :entries do
    desc "Deliver the entry mailing list content for a given day"
    task :deliver => :environment do
      if ENV['DATE'].present?
        date = Date.parse(ENV['DATE'])
      else
        date = Date.current
      end
      
      puts `cd /var/www/apps/my_fr2 && bundle exec rake mailing_lists:articles:deliver["#{date.to_s(:iso)}"]`
    end
  end
end
