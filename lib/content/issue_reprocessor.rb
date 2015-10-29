module Content
  class IssueReprocessor
    include CacheUtils
    include Content::IssueReprocessorUtils

    @queue = :default

    attr_reader :reprocessed_issue

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find(reprocessed_issue_id)
    end

    def self.perform(reprocessed_issue_id)
      new(reprocessed_issue_id).perform
    end

    def perform
      rotate_mods_files
      reprocess_issue
      reindex
      clear_cache
      update_status("complete")
    end

    def date
      @date ||= @reprocessed_issue.publication_date
    end

    def reprocess_issue
      reprocess_basic_data
      reprocess_events
      reprocess_agencies
    end

    private

    def reprocess_basic_data
      update_reprocessing_message("reprocessing basic data")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:basic_data'].invoke
      rescue Exception => error
        handle_failure(error,"IssueReprocessor: Reprocess Basic Data")
      end
    end

    def reprocess_events
      update_reprocessing_message("reprocessing dates")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:events'].invoke
      rescue Exception => error
        handle_failure(error,"IssueReprocessor: Reprocess Events")
      end
    end

    def reprocess_agencies
      update_reprocessing_message("reprocessing agencies")

      begin
        ENV['DATE'] = "#{date.to_s(:iso)}"
        Rake::Task['content:entries:import:agencies'].invoke
      rescue Exception => error
        handle_failure(error,"IssueReprocessor: Reprocess Agencies")
      end
    end

    def reindex
      update_reprocessing_message("updating search index")

      begin
        line = Cocaine::CommandLine.new(
          "/usr/local/bin/indexer",
          "-c :sphinx_conf --rotate entry_delta",
          :environment => {'DATE' => "#{date.to_s(:iso)}"}
        )
        line.run(:sphinx_conf => "config/#{Rails.env}.sphinx.conf")
      rescue Cocaine::ExitStatusError => error
        handle_failure(error,"IssueReprocessor::ReprocessorIssue Reindex")
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
      FileUtils.makedirs(archive_mods_path)
      FileUtils.mv(
        File.join(mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(archive_mods_path, "#{date.to_s(:iso)}-#{Time.now.to_i}.xml")
      )
      FileUtils.makedirs(temporary_mods_path)
      FileUtils.mv(
        File.join(temporary_mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(mods_path, "#{date.to_s(:iso)}.xml")
      )
    end

  end
end
