module Content
  class IssueReprocessor
    include CacheUtils
    include Content::IssueReprocessorUtils
    include SphinxIndexer

    @queue = :api_core

    attr_reader :path_manager, :reprocessed_issue

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find(reprocessed_issue_id)
      @path_manager = FileSystemPathManager.new(@reprocessed_issue.issue.publication_date)
    end

    def self.perform(reprocessed_issue_id)
      ActiveRecord::Base.verify_active_connections!

      new(reprocessed_issue_id).perform
    end

    def perform
      rotate_mods_files
      reprocess_issue
      reindex
      regenerate_toc_json
      clear_cache
      update_status("complete")
    end

    def date
      @date ||= @reprocessed_issue.publication_date
    end

    def reprocess_issue
      reprocess_basic_data
      reprocess_rin_and_significant
      reprocess_presdoc_fields
      reprocess_events
      reprocess_agencies
    end

    private

    def reprocess_basic_data
      update_reprocessing_message("reprocessing basic data")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:basic_data'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Basic Data")
      end
    end

    def reprocess_rin_and_significant
      update_reprocessing_message("reprocessing RIN and Significant flag")
      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:rin_and_significant'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess RIN and Significant")
      end
    end

    def reprocess_events
      update_reprocessing_message("reprocessing dates")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:events'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Events")
      end
    end

    def reprocess_agencies
      update_reprocessing_message("reprocessing agencies")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:agencies'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Agencies")
      end
    end

    def reprocess_presdoc_fields
      update_reprocessing_message("reprocessing presidential document fields")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:presidential_documents'].invoke
      rescue StandardError => error
        handle_failure(error,"IssueReprocessor: Reprocess Presidential Documents")
      end
    end

    def reindex
      update_reprocessing_message("updating search index")

      begin
        SphinxIndexer.rebuild_delta_and_purge_core(Entry)
      rescue SphinxIndexer::SphinxIndexerError => error
        handle_failure(error,"IssueReprocessor::ReprocessorIssue Reindex")
      end
    end

    def regenerate_toc_json
      if date < XmlTableOfContentsTransformer::GPO_XML_START_DATE
        update_reprocessing_message("regenerating table of contents")

        begin
          purge_cache('^/api/v1/documents')
          ENV['DATE'] = "#{date.to_s(:iso)}"
          Rake::Task['content:entries:json:compile:daily_toc'].invoke
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
