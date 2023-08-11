namespace :content do
  namespace :public_inspection do
    desc "Import current public inspection data"

    namespace :import do
      desc "Link public inspection documents to their entries based on publication date"
      task :entry_id => :environment do
        dates = Content.parse_dates(ENV['DATE'] || Date.current)

        dates.each do |date|
          begin
            puts "linking PI for #{date}"
            PublicInspectionDocument.where(publication_date: date, entry_id: nil).each do |pi_doc|
              pi_doc.entry = Entry.find_by_document_number(pi_doc.document_number)
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
      if Issue.should_have_an_issue?(Date.current)
        Content::BatchedPublicInspectionImporter.perform
      end
    end

    task :reindex => :environment do
      begin
        PublicInspectionIndexer.reindex!
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
        PublicInspectionIndexer.reindex!
      end

      Content::PublicInspectionImporter::BatchedPublicInspectionImporterFinisher.new.generate_toc(args[:date])
    end

    namespace :blacklist do
      task :add, [:document_number] => :environment do |t, args|
        $redis.sadd(
          Content::BatchedPublicInspectionImporter::BLACKLIST_KEY,
          args[:document_number]
        )

        puts "Current blacklist: #{$redis.smembers(Content::BatchedPublicInspectionImporter::BLACKLIST_KEY)}"
      end

      task :remove, [:document_number] => :environment do |t,args|
        $redis.srem(
          Content::BatchedPublicInspectionImporter::BLACKLIST_KEY,
          args[:document_number]
        )

        puts "Current blacklist: #{$redis.smembers(Content::BatchedPublicInspectionImporter::BLACKLIST_KEY)}"
      end
    end

    task :destroy_published_agency_letters => :environment do
      PilAgencyLetterJanitor.new.perform
    end

  end
end
