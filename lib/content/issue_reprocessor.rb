module Content
  class IssueReprocessor
    include CacheUtils
    include Content::IssueReprocessorUtils

    include Sidekiq::Worker
    include Sidekiq::Throttled::Worker

    sidekiq_options :queue => :reimport, :retry => 0

    attr_reader :path_manager, :reprocessed_issue, :force_reload_bulkdata

    def perform(reprocessed_issue_id, force_reload_bulkdata = false)
      ActiveRecord::Base.clear_active_connections!
      @reprocessed_issue = ReprocessedIssue.find(reprocessed_issue_id)
      update_created_at!
      @path_manager      = FileSystemPathManager.new(@reprocessed_issue.issue.publication_date)
      @force_reload_bulkdata = force_reload_bulkdata

      remaining_retries = 1
      begin
        rotate_mods_files
      rescue Errno::ENOENT => error
        # Attempt to re-download mods if they are absent from the temp mods directory
        if remaining_retries > 0
          reprocessed_issue.download_mods(async: false)
          remaining_retries -= 1
          retry
        else
          raise error
        end
      end

      reprocess_issue
      reindex
      regenerate_toc_json
      notify_of_updated_issue
      clear_cache

      if reprocessed_issue.status != 'failed' # ie Don't mark a reprocessing as "complete" if rescues occurred in #handle_failures
        update_status("complete")
      end
    end

    def date
      @date ||= @reprocessed_issue.publication_date
    end

    def reprocess_issue
      reimport_data
      reprocess_rin_and_significant
      reprocess_presdoc_fields
      reprocess_events
      reprocess_agencies
      reprocess_page_counts
    end

    private

    def update_created_at!
      if reprocessed_issue.user_id == AutomaticModsReprocessor::AUTOMATED_REPROCESS_USER_ID &&
        date != Issue.current.publication_date
        reprocessed_issue.update!(created_at: Time.current)
      end
    end

    def notify_of_updated_issue
      update_reprocessing_message("enqueuing recompilation of HTML")

      begin
        Sidekiq::Client.push(
          'class' => 'IssueReprocessor',
          'args'  => [date.to_s(:iso)],
          'queue' => 'issue_reprocessor',
          'retry' => 0
        )
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: enqueuing recompilation of HTML")
      end
    end

    def reimport_data
      update_reprocessing_message("reimporting all entry data")

      begin
        if force_reload_bulkdata
          entry_importer(:all, {force_reload_bulkdata: true, force_reload_mods: true})
        else
          entry_importer(:all, {force_reload_bulkdata: false, force_reload_mods: false})
        end
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reimporting all entry data")
      end
    end

    def reprocess_rin_and_significant
      update_reprocessing_message("reprocessing RIN and Significant flag")
      begin
        entry_importer(:regulation_id_numbers, :significant)
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess RIN and Significant")
      end
    end

    def reprocess_events
      update_reprocessing_message("reprocessing dates")

      begin
        entry_importer(:events)
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Events")
      end
    end

    def reprocess_agencies
      update_reprocessing_message("reprocessing agencies")

      begin
        entry_importer(:agency_name_assignments)
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Agencies")
      end
    end

    def reprocess_presdoc_fields
      update_reprocessing_message("reprocessing presidential document fields")

      begin
        entry_importer(:presidential_document_type_id, :signing_date, :executive_order_notes, :presidential_document_number, :president_id)
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Presidential Documents")
      end
    end

    def reprocess_page_counts
      update_reprocessing_message("reprocessing issue page counts")

      begin
        import_issue!
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Issue")
      end
    end

    def import_issue!
      issue = Issue.find_by_publication_date!(date)
      Content::EntryImporter::IssueUpdater.new(
        issue,
        Content::EntryImporter::ModsFile.new(issue.publication_date, false),
        Content::EntryImporter::BulkdataFile.new(issue.publication_date, false)
      ).process
    end

    def reindex
      update_reprocessing_message("updating search index")

      begin
        ElasticsearchIndexer.handle_entry_changes
      rescue StandardError => error
        handle_failure(error, "Elasticsearch Entry Change Reindexing")
      end
    end

    def regenerate_toc_json
      if date < XmlTableOfContentsTransformer::GPO_XML_START_DATE
        update_reprocessing_message("regenerating table of contents")

        begin
          purge_cache('^/api/v1/documents')
          compile_toc_json!
          purge_cache("^/api/v1/issues/#{date.strftime("%Y/%m/%d")}*")
        rescue StandardError => error
          handle_failure(error,"IssueReprocessor: Regenerate ToC JSON")
        end
      end
    end

    def update_reprocessing_message(message)
      time = Time.now.in_time_zone.to_s(:short_date_then_time)
      update_message("#{time}: #{message}...")
    end

    def handle_failure(error, error_class)
      Honeybadger.notify(
        :error_class   => error_class,
        :error_message => error.message,
        :backtrace => error.backtrace,
        :parameters => {
          :reprocessed_issue_id => reprocessed_issue.id,
          :date => date
        }
      )
      update_status("failed")
    end

    def clear_cache
      purge_cache('/')
    end

    def rotate_mods_files
      FileUtils.mkdir_p(path_manager.document_archive_mods_dir)

      if File.exist?(path_manager.document_mods_path) #ie don't assume MODS exist
        FileUtils.mv(
          path_manager.document_mods_path,
          path_manager.document_archive_mods_path(Time.now.to_i)
        )
      end

      FileUtils.mkdir_p(path_manager.document_temporary_mods_dir)
      FileUtils.mv(
        path_manager.document_temporary_mods_path,        path_manager.document_mods_path
      )
    end

    def entry_importer(*attributes)
      Content::EntryImporter.process_all_by_date(date, *attributes)
    end

    def compile_toc_json!
      return unless Issue.should_have_an_issue?(date)

      puts "compiling daily table of contents json for #{date}..."
      Content::TableOfContentsCompiler.perform(date)
    end

  end
end
