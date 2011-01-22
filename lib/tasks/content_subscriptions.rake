namespace :content do
  namespace :mailing_lists do
    desc "deliver daily mailing lists"
    task :deliver do
      date = ENV['DATE'] || Time.current.to_date
      
      MailingList.active.each do |mailing_list|
        results = mailing_list.search_results_for(date)
        
        unless results.empty?
          mailing_list.active_subscriptions.find_in_batches(:batch_size => 1000).each do |subscriptions|
            Mailer.deliver_mailing_list(mailing_list, results, subscriptions)
          end
        end
      end
    end
  end
end