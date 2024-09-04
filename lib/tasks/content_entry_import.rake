namespace :content do
  namespace :entries do
    def entry_importer(*attributes)
      date = ENV['DATE'] || Time.current.to_date
      Content::EntryImporter.process_all_by_date(date, *attributes)
    end

    desc "Import all entry data"
    task :import => :environment do
      entry_importer(:all, {force_reload_bulkdata: true, force_reload_mods: true})
    end

    desc "Reimport all entry data, forcing bulk data download"
    task :reimport => :environment do
      entry_importer(:all, {force_reload_bulkdata: true, force_reload_mods: true})
    end

    desc "Reimport all entry data, NOT forcing bulk data download"
    task :reimport_sans_force_reload => :environment do
      entry_importer(:all, {force_reload_bulkdata: false, force_reload_mods: false})
    end

    desc "Enqueue regulations dot gov import"
    task :enqueue_regs_dot_gov_import => :environment do
      dates = Content.parse_all_dates(ENV['DATE'])
      dates.each do |date|
        entries = Entry.select('document_number').where(publication_date: date)

        entries.each do |entry|
          Sidekiq::Client.enqueue(
            EntryRegulationsDotGovImporter,
            entry.document_number,
            date.to_s(:iso)
          )
        end
      end
    end

    namespace :import do
      desc "Enqueue a rake task as a background job"
      task :enqueue, [:task, :dates] => :environment do |t, args|
        dates = Content.parse_dates(args[:dates])
        dates.each do |date|
          Sidekiq::Client.enqueue(RakeTaskDateEnqueuer, args[:task], date.to_s(:iso))
        end
      end

      desc "Extract Basic data"
      task :basic_data => :environment do
        entry_importer(:volume, :issue_number, :title, :toc_subject, :toc_doc, :citation, :start_page, :end_page, :part_name, :granule_class, :abstract, :dates, :action, :contact, :docket_numbers, :correction_of_id, :xml_based_dates)
      end

      desc "Extract full text"
      task :full_text => :environment do
        entry_importer(:full_text)
      end

      desc "Extract full_xml"
      task :full_xml => :environment do
        entry_importer(:full_xml)
      end

      desc "Extract raw_text"
      task :raw_text => :environment do
        entry_importer(:raw_text)
      end

      desc "Extract full_xml & raw_text"
      task :full_xml_and_raw_text => :environment do
        entry_importer(:full_xml, :raw_text)
      end

      desc "Citations"
      task :citations => :environment do
        entry_importer(:citations)
      end

      desc "Extract pages"
      task :pages => :environment do
        entry_importer(:start_page, :end_page)
      end

      desc "Extract regulation_id_numbers and significant"
      task :rin_and_significant => :environment do
        entry_importer(:regulation_id_numbers, :significant)
      end

      desc "Extract docket numbers"
      task :docket_numbers => :environment do
        entry_importer(:docket_numbers)
      end

      desc "Extract events"
      task :events => :environment do
        entry_importer(:events)
      end

      desc "Extract Presidential Document Data"
      task :presidential_documents => :environment do
        entry_importer(:presidential_document_type_id, :signing_date, :executive_order_notes, :presidential_document_number, :president_id)
      end

      desc "Extract Action Name"
      task :action_name => :environment do
        entry_importer(:action_name)
      end

      desc "Extract CFR information into entries"
      task :cfr => :environment do
        entry_importer(:entry_cfr_references)
      end

      desc "Extract Issue Number into entries"
      task :issue_number => :environment do
        entry_importer(:issue_number)
      end

      desc "Import regulations.gov info"
      task :regulations_dot_gov => :environment do
        entry_importer(:checked_regulationsdotgov_at, :regulationsdotgov_url, :comment_url, :regulations_dot_gov_comments_close_on, :regulations_dot_gov_docket_id)
      end

      desc "Import Issue Data"
      task :issue => :environment do
        issue = Issue.find_by_publication_date!(ENV['DATE'] || Time.current.to_date)
        Content::EntryImporter::IssueUpdater.new(
          issue,
          Content::EntryImporter::ModsFile.new(issue.publication_date, false),
          Content::EntryImporter::BulkdataFile.new(issue.publication_date, false)
       ).process
      end

      namespace :regulations_dot_gov do
        def update_missing_regulationsdotgov_info(date = nil)
          entries = Entry.scoped(:conditions => ["checked_regulationsdotgov_at IS NULL or checked_regulationsdotgov_at < ?", 25.minutes.ago])
          if date
            entries = entries.scoped(:conditions => {:publication_date => date})
          else
            entries = entries.scoped(:conditions => {:publication_date => (4.months.ago .. Issue.current.publication_date.to_time)}).scoped(:conditions => "comment_url IS NOT NULL")
          end

          entries.find_each do |entry|
            Sidekiq::Client.enqueue(
              EntryRegulationsDotGovImporter,
              entry.document_number,
              date.try(:to_s, :iso)
            )
          end

        end

        desc "Bulk update regulations.gov info for entries modified today"
        task :modified_today => :environment do
          puts "Updating regulations.gov info for entries modified today"
          RegulationsDotGov::RecentlyModifiedDocumentUpdater.new(0).perform
        end

        desc "Mark documents as closed for commenting if past comment close date"
        task :mark_documents_as_closed_for_commenting => :environment do
          puts "Reimport documents that have 'closed' per their comment close date to ensure comment url is marked as nil"
          CommentPeriodCloser.perform
        end

        desc "Import regulations.gov info for entries missing it published today"
        task :only_missing => :environment do
          puts "importing today's missing regulations.gov data"
          update_missing_regulationsdotgov_info(Date.current)
        end

        desc "Import regulations.gov info for entries missing it published in the last 3 weeks"
        task :tardy => :environment do
          update_missing_regulationsdotgov_info(3.weeks.ago .. Time.now)
        end

        desc "Confirm comment periods are still open for comments in the last few months"
        task :open_comments => :environment do
          include CacheUtils
          update_missing_regulationsdotgov_info
          purge_cache("/api/v1/*")
        end
      end

      desc "Assign entries to sections"
      task :sections => :environment do
        # entry_importer(:sections)
        sections = Section.all(:include => :agencies)
        Content.parse_dates(ENV['DATE']).each do |date|
          puts "handling #{date}..."
          Entry.published_on(date).scoped(:include => [:agencies, :sections]).each do |entry|
            entry.section_ids = sections.select{|s| s.should_include_entry?(entry)}.map(&:id)
            entry.save
          end
        end
      end

      desc "Extract agency information into entries"
      task :agencies => :environment do
        entry_importer(:agency_name_assignments)
      end

      desc "Import graphics"
      task :graphics => :environment do
        # evetually logic needs to be moved into entryimporter...
        date = ENV['DATE']

        if date.nil?
          dates = [Time.current.to_date]
        elsif date == 'all'
          sql = Entry.select("distinct(publication_date) AS publication_date").
            order("publication_date").
            to_sql
          dates = Entry.find_as_array(sql)
        elsif date =~ /^>/
          date = Date.parse(date.sub(/^>/, ''))
          sql = Entry.
            select("distinct(publication_date) AS publication_date").
            where(:publication_date => date .. Time.current.to_date).
            order("publication_date").
            to_sql
          dates = Entry.find_as_array(sql)
        elsif date =~ /^\d{4}$/
          sql = Entry.
            select("distinct(publication_date) AS publication_date").
            where(:publication_date => Date.parse("#{date}-01-01") .. Date.parse("#{date}-12-31")).
            order("publication_date").
            to_sql
          dates = Entry.find_as_array(sql)
        elsif date =~ /^\d{4}-\d{2}-\d{2}$/
          dates = [date]
        else
          raise "INVALID FORMAT"
        end

        dates.each do |date|
          Content::GraphicsExtractor.new(date).perform
        end
      end
    end
  end
end
