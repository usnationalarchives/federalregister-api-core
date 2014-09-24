namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"
    task :import => :environment do
      Content::PublicInspectionImporter.perform

      Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'
    end

    namespace :import do
      desc "Link public inspection documents to their entries based on publication date"
      task :entry_id => :environment do
        dates = Content.parse_dates(ENV['DATE'] || Date.current)

        dates.each do |date|
          puts "linking PI for #{date}"
          PublicInspectionDocument.find_all_by_publication_date_and_entry_id(date, nil).each do |pi_doc|
            pi_doc.entry = Entry.find_by_document_number(pi_doc.document_number)
            pi_doc.save(false)
          end
        end
      end
    end

    task :import_and_deliver => :environment do
      Content::ImportDriver::PublicInspectionDriver.new.perform
    end

    task :run => :environment do
      new_document_numbers = Content::PublicInspectionImporter.perform

      if new_document_numbers.present?
        Rake::Task["content:public_inspection:reindex"].invoke unless Rails.env == 'development'

        document_numbers = new_document_numbers.join(';')
        Content.run_myfr2_command "bundle exec rake mailing_lists:public_inspection:deliver[\"#{document_numbers}\"]"
      end
    end

    task :reindex => :environment do
      SphinxIndexer.perform('public_inspection_document_core')
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
