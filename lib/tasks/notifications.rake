namespace :notifications do
  namespace :content do
    desc "Triggers emails/pager duty if content is late"
    task :late => :environment do
      return unless Rails.env.production?

      if Issue.current_issue_is_late?("7AM")
        date = Time.current.to_date
        messages = []
        
        if Issue.bulk_data_missing?
          messages << "Bulkdata XML file for #{date} is not available. It is expected to be present at #{Content::EntryImporter::BulkdataFile.new(date).url}"
        end

        if Issue.mods_missing?
          messages << "MODS XML file for #{date} is not available. It is expected to be present at #{Content::EntryImporter::ModsFile.new(date).url}"
        end

        Mailer.ofr_gpo_content_notification(messages.join("\n\n")).deliver_now unless messages.empty?
      end

      if Issue.current_issue_is_late?("8AM")
        Mailer.pager_duty("FR content is late!").deliver_now
      end
    end
  end
end
