namespace :mailing_lists do
  desc "Deliver the mailing list content for a given day"
  task :deliver => :environment do
    if ENV['DATE'].present?
      date = Date.parse(ENV['DATE'])
    else
      date = Date.current
    end
    
    MailingList.active.find_each do |mailing_list|
      mailing_list.deliver!(date, :force_delivery => ENV['FORCE_DELIVERY'])
    end
  end
end
