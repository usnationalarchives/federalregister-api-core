namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"
    task :import => :environment do
      Content::PublicInspectionImporter.perform

      Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'
    end

    task :import_and_deliver => :environment do
      Content::ImportDriver::PublicInspectionDriver.new.perform
    end

    task :run => :environment do
      new_documents = Content::PublicInspectionImporter.perform

      Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'

      MailingList::PublicInspectionDocument.active.find_each do |mailing_list|
        begin
          mailing_list.deliver!(new_documents)
        rescue Exception => e
          Rails.logger.warn(e)
          Airbrake.notify(e)
        end
      end
    end

    task :reindex do
      if RAILS_ENV == 'development'
        `indexer -c /Users/andrewcarpenter/Documents/federal_register/fr2/config/development.sphinx.conf public_inspection_document_core --rotate`
      else
        `bundle exec cap #{RAILS_ENV} sphinx:public_inspection:reindex`
      end
    end

    task :purge_revoked_documents => :environment do
      # after 5:15, purge PDFs
      if Time.current >= Time.zone.parse("5:15PM")
        revoked_documents = PublicInspectionIssue.current.public_inspection_documents.revoked
        issues = []
        revoked_documents.each do |document|
          document.make_s3_files_private!
          issues << document.public_inspection_issues
        end

        # have the after_save observer purge the cache for all affected issues
        issues.uniq.each do |issue|
          issue.touch(:updated_at)
        end
      end
    end
  end
end
