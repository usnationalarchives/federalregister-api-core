module Content
  class IssueReprocessor
    include CacheUtils
    include Content::IssueReprocessorUtils

    @queue = :default

    attr_reader :reprocessed_issue, :date, :current_mods_path, :mods_archive_path,
                :temporary_mods_path

    def initialize(reprocessed_issue_id, options={})
      @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
      @date = @reprocessed_issue.publication_date
      @current_mods_path = options[:current_mods_path] || File.join('data','mods')
      @temporary_mods_path = options[:temporary_mods_path] || File.join('data','mods','tmp')
      @mods_archive_path = options[:mods_archive_path] || File.join('data','mods','archive')
    end

    def self.perform(reprocessed_issue_id, options={})
      new(reprocessed_issue_id, options).perform
    end

    def perform
      rotate_mods_files
      reprocess_issue
      reindex
      clear_cache
      update_status("complete")
    end

    private

    def reprocess_issue
      reprocess_events
      reprocess_agencies
    end

    def reprocess_events
      update_message("#{Time.now.to_s(:short_date_then_time)}: reprocessing dates...")
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
      update_message("#{Time.now.to_s(:short_date_then_time)}: reprocessing agencies...")
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
      update_message("#{Time.now.to_s(:short_date_then_time)}: updating search index...")
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
      FileUtils.makedirs(mods_archive_path)
      FileUtils.mv(
        File.join(current_mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(mods_archive_path, "#{date.to_s(:iso)}-#{Time.now.to_i}.xml")
      )
      FileUtils.makedirs(temporary_mods_path)
      FileUtils.mv(
        File.join(temporary_mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(current_mods_path, "#{date.to_s(:iso)}.xml")
      )
    end

  end
end
