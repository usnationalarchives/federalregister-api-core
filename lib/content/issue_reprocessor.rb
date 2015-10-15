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

    private

    def date
      @date ||= @reprocessed_issue.publication_date
    end

    def reprocess_issue
      reprocess_events
      reprocess_agencies
    end

    def reprocess_events
      update_message("#{Time.now.in_time_zone.to_s(:short_date_then_time)}: reprocessing dates...")

      begin
        line = Cocaine::CommandLine.new(
          "bundle exec rake",
          ":task",
          :environment => {'DATE' => "#{date.to_s(:iso)}"}
        )
        line.run(:task => "content:entries:import:events")
      rescue Cocaine::ExitStatusError => e
        Honeybadger.notify(
          :error_class   => "IssueReprocessor::ReprocessorIssue Error",
          :error_message => e.message,
          :parameters => {
            :reprocessed_issue_id => reprocessed_issue.id,
            :date => date
          }
        )
        update_status("failed")
      end
    end

    def reprocess_agencies
      update_message("#{Time.now.in_time_zone.to_s(:short_date_then_time)}: reprocessing agencies...")

      begin
        line = Cocaine::CommandLine.new(
          "bundle exec rake",
          ":task",
          :environment => {'DATE' => "#{date.to_s(:iso)}"}
        )
        line.run(:task => "content:entries:import:agencies")
      rescue Cocaine::ExitStatusError => e
        Honeybadger.notify(
          :error_class   => "IssueReprocessor::ReprocessorIssue Error",
          :error_message => e.message,
          :parameters => {
            :reprocessed_issue_id => reprocessed_issue.id,
            :date => date
          }
        )
        update_status("failed")
      end
    end

    def reindex
      update_message("#{Time.now.in_time_zone.to_s(:short_date_then_time)}: updating search index...")

      begin
        line = Cocaine::CommandLine.new(
          "/usr/local/bin/indexer",
          "-c :sphinx_conf --rotate entry_delta",
          :environment => {'DATE' => "#{date.to_s(:iso)}"}
        )
        line.run(:sphinx_conf => "config/#{Rails.env}.sphinx.conf")
      rescue Cocaine::ExitStatusError => e
        Honeybadger.notify(
          :error_class   => "IssueReprocessor::ReprocessorIssue Error",
          :error_message => e.message,
          :parameters => {
            :reprocessed_issue_id => reprocessed_issue.id,
            :date => date
          }
        )
        update_status("failed")
      end
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
