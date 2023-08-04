module Content
  class IssueReprocessor
    include CacheUtils
    include Content::IssueReprocessorUtils

    include Sidekiq::Worker
    include Sidekiq::Throttled::Worker

    sidekiq_options :queue => :reimport, :retry => 0

    attr_reader :path_manager, :reprocessed_issue

    def perform(reprocessed_issue_id)
      ActiveRecord::Base.clear_active_connections!
      @reprocessed_issue = ReprocessedIssue.find(reprocessed_issue_id)
      @path_manager      = FileSystemPathManager.new(@reprocessed_issue.issue.publication_date)
      Rails.application.load_tasks

      rotate_mods_files
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

    def notify_of_updated_issue
      update_reprocessing_message("enqueuing recompilation of HTML")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['web:notify_of_updated_issue'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: enqueuing recompilation of HTML")
      ensure
        Rake::Task['web:notify_of_updated_issue'].reenable
      end
    end

    def reimport_data
      update_reprocessing_message("reimporting all entry data")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:reimport_sans_force_reload'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reimporting all entry data")
      ensure
        Rake::Task['content:entries:reimport_sans_force_reload'].reenable
      end
    end

    def reprocess_rin_and_significant
      update_reprocessing_message("reprocessing RIN and Significant flag")
      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:rin_and_significant'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess RIN and Significant")
      ensure
        Rake::Task['content:entries:import:rin_and_significant'].reenable
      end
    end

    def reprocess_events
      update_reprocessing_message("reprocessing dates")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:events'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Events")
      ensure
        Rake::Task['content:entries:import:events'].reenable
      end
    end

    def reprocess_agencies
      update_reprocessing_message("reprocessing agencies")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:agencies'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Agencies")
      ensure
        Rake::Task['content:entries:import:agencies'].reenable
      end
    end

    def reprocess_presdoc_fields
      update_reprocessing_message("reprocessing presidential document fields")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:presidential_documents'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Presidential Documents")
      ensure
        Rake::Task['content:entries:import:presidential_documents'].reenable
      end
    end

    def reprocess_page_counts
      update_reprocessing_message("reprocessing issue page counts")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:issue'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Issue")
      ensure
        Rake::Task['content:entries:import:issue'].reenable
      end
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
          ENV['DATE'] = "#{date.to_s(:iso)}"
          Rake::Task['content:entries:json:compile:daily_toc'].invoke
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
      FileUtils.mv(
        path_manager.document_mods_path,
        path_manager.document_archive_mods_path(Time.now.to_i)
      )

      FileUtils.mkdir_p(path_manager.document_temporary_mods_dir)
      FileUtils.mv(
        path_manager.document_temporary_mods_path,
        path_manager.document_mods_path
      )
    end

  end
end
