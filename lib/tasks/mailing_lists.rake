namespace :mailing_lists do
  desc "Deliver the mailing list content for a given day"
  task :deliver => :environment do
    if ENV['DATE'].present?
      date = ENV['DATE']
    else
      date = Date.current.to_s
    end
    
    MailingList.active.find_each do |mailing_list|
      search = mailing_list.search
      search.publication_date = {:is => date}
      search.per_page = 1000
      
      results = search.results
      
      unless results.empty?
        # TODO: refactor to find_in_batches and use sendgrid to send to 1000 subscribers at once
        mailing_list.active_subscriptions.find_each do |subscription|
          # TODO: exclude non-developers from receiving emails in development mode
          Mailer.deliver_mailing_list(mailing_list, results, [subscription])
          Subscription.update_all(
            ['delivery_count = delivery_count + 1, last_delivered_at = ?', Time.now],
            {:id => subscription.id}
          )
          
          puts "delivered #{mailing_list.id} (#{results.size}) to #{subscription.email}"
        end
      end
    end
  end
end