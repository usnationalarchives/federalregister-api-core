class IssueReprocessor::ReprocessorIssue
  include CacheUtils

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

  def reprocess_issue
    reprocess_events
    reprocess_agencies
  end

  def reprocess_events
    update_message("#{Time.now.to_s(:short_date_then_time)}: reprocessing dates...")

    unless run_cmd("bundle exec rake content:entries:import:events DATE=#{date.to_s(:iso)}")
      update_status("failed")
    end
  end

  def reprocess_agencies
    update_message("#{Time.now.to_s(:short_date_then_time)}: reprocessing agencies...")

    unless run_cmd("bundle exec rake content:entries:import:agencies DATE=#{date.to_s(:iso)}")
      update_status("failed")
    end
  end

  def reindex
    update_message("#{Time.now.to_s(:short_date_then_time)}: updating search index...")

    unless run_cmd("/usr/local/bin/indexer -c config/#{Rails.env}.sphinx.conf --rotate entry_delta")
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

  def update_status(status)
    reprocessed_issue.update_attributes(:status => status)
  end

  private

  def run_cmd(shell_command)
    errors, stdout = nil, nil
    shell_connection = Open4::popen4(shell_command) do |pid, stdin, stdout, stderr|
      errors = stderr.read.strip
      stdout = stdout.read.strip
    end

    if shell_connection.exitstatus != 0
      Honeybadger.notify(
        :error_class   => "IssueReprocessor::ReprocessorIssue Error",
        :error_message => errors,
        :parameters => {
          :reprocessed_issue_id => reprocessed_issue.id,
          :date => date
        }
      )
      return false
    else
      log("[#{Time.now}] id: #{reprocessed_issue.id} \n Standard Out for '#{shell_command}': #{stdout}")
      return true
    end
  end

  def update_message(text)
    message = reprocessed_issue.message || ""
    message << "\n- #{text}"

    reprocessed_issue.message = message
    reprocessed_issue.save!
  end

  def logger
    @logger ||= Logger.new(log_path)
  end

  def log(message)
    logger.info("#{Time.current.to_s(:time_then_date)}: #{message}")
  end

  def log_path
    "#{Rails.root}/log/reprocessor_issue.log"
  end
end
