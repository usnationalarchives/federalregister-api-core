namespace :notifications do
  namespace :content do
    desc "Triggers pager duty if content is late"
    task :late => :environment do
      next unless Rails.env.production?
      date = Date.current

      if Issue.current_issue_is_late?("8AM") && !Issue.bulk_data_missing?(date) && !Issue.mods_missing?(date)
        Mailer.pager_duty("FR content is late!").deliver_now
      end
    end

    desc "Triggers emails if content is late and missing"
    task :missing => :environment do
      next unless Rails.env.production?

      if Issue.current_issue_is_late?("7AM")
        date = Time.current.to_date
        messages = []
        
        if Issue.bulk_data_missing?(date)
          messages << "Bulkdata XML file for #{date} appears to be unavailable. It is expected to be present at #{Content::EntryImporter::BulkdataFile.new(date).url}"
        end

        if Issue.mods_missing?(date)
          messages << "MODS XML file for #{date} appears to be unavailable. It is expected to be present at #{Content::EntryImporter::ModsFile.new(date).url}"
        end

        Mailer.ofr_gpo_content_notification(messages.join("\n\n")).deliver_now unless messages.empty?
      end
    end
  end
end
