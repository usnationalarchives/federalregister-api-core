class IssueReprocessor::ManualReprocessorIssue
  include CacheUtils

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
    reprocess_issue
    archive_mods_files
    update_status
  end

  def reprocess_issue
    update_message("#{Time.now.to_s(:short_date_then_time)}: processing dates...")
    run_cmd("bundle exec rake content:entries:import:events DATE=#{date.to_s(:iso)}")
    update_message("#{Time.now.to_s(:short_date_then_time)}: processing agencies...")
    run_cmd("bundle exec rake content:entries:import:agencies DATE=#{date.to_s(:iso)}")
  end

  def archive_mods_files
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

  def update_status
    reprocessed_issue.update_attributes(:status => "complete")
  end

  private

  def run_cmd(shell_command)
    errors, stdout = nil, nil
    shell_connection = Open4::popen4(shell_command) do |pid, stdin, stdout, stderr|
      errors = stderr.read.strip
      stdout = stdout.read.strip
    end
    if shell_connection.exitstatus != 0
      Honeybadger.notify("Error while reprocessing issue: #{errors}")
      raise "Errors importing issue: #{errors}"
    else
      log("Standard Out for '#{shell_command}': #{stdout}")
    end
  end

  def update_message(text)
    if reprocessed_issue.message
      message = reprocessed_issue.message
    else
      message = ""
    end
    message << "\n- #{text}"
    reprocessed_issue.message = message
    reprocessed_issue.save!
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/reprocessor_issue.log")
  end

  def log(message)
    logger.info("#{Time.current.to_s(:time_then_date)}: #{message}")
  end

end
