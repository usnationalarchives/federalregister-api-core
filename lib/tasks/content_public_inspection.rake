namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"
    task :import => :environment do
      Content::PublicInspectionImporter.perform if Issue.should_have_an_issue?(Date.current)
    end

    namespace :import do
      desc "Link public inspection documents to their entries based on publication date"
      task :entry_id => :environment do
        dates = Content.parse_dates(ENV['DATE'] || Date.current)

        dates.each do |date|
          begin
            puts "linking PI for #{date}"
            PublicInspectionDocument.where(publication_date: date, entry_id: nil).each do |pi_doc|
              pi_doc.entry = Entry.find_by_document_number(pi_doc.document_number)
              pi_doc.delta = true
              pi_doc.save(validate: false)
            end
          rescue StandardError => e
            puts e.message
            puts e.backtrace.join("\n")
            Honeybadger.notify(e)
          end
        end
      end
    end

    task :import_and_deliver => :environment do
      Content::ImportDriver::PublicInspectionDriver.new.perform
    end

    task :run => :environment do
      if Issue.should_have_an_issue?(Date.current)
        new_document_numbers = Content::PublicInspectionImporter.perform

        if new_document_numbers.present?
          Resque.enqueue_to(:subscriptions, 'PublicInspectionDocumentSubscriptionQueuePopulator', new_document_numbers)
        end
      end
    end

    task :reindex => :environment do
      begin
        PublicInspectionIndexer.reindex!
        SphinxIndexer.perform('public_inspection_document_core')
      rescue StandardError => e
        puts e.message
        puts e.backtrace.join("\n")
        Honeybadger.notify(e)
      end
    end

    task :reindex_elasticsearch => :environment do
      PublicInspectionIndexer.reindex!
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

    task :regenerate_toc, [:date] => :environment do |t, args|
      if ENV['REINDEX']
        SphinxIndexer.perform('public_inspection_document_core')
        PublicInspectionIndexer.reindex!
      end

      pil = Content::PublicInspectionImporter.new
      pil.generate_toc(args[:date])
    end

    namespace :blacklist do
      task :add, [:document_number] => :environment do |t, args|
        $redis.sadd(
          Content::PublicInspectionImporter::BLACKLIST_KEY,
          args[:document_number]
        )

        puts "Current blacklist: #{$redis.smembers(Content::PublicInspectionImporter::BLACKLIST_KEY)}"
      end

      task :remove, [:document_number] => :environment do |t,args|
        $redis.srem(
          Content::PublicInspectionImporter::BLACKLIST_KEY,
          args[:document_number]
        )

        puts "Current blacklist: #{$redis.smembers(Content::PublicInspectionImporter::BLACKLIST_KEY)}"
      end
    end
  end
end
