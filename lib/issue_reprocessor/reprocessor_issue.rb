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
    reprocess_issue
    reindex
    clear_cache
    archive_mods_files
    update_status
  end

  def reprocess_issue
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      update_message("#{Time.now.to_s(:short_date_then_time)}: processing dates...")
      stdin.puts "bundle exec rake content:entries:import:events DATE=#{date.to_s(:iso)}"
      update_message("#{Time.now.to_s(:short_date_then_time)}: processing agencies...")
      stdin.puts "bundle exec rake content:entries:import:agencies DATE=#{date.to_s(:iso)}"
      stdin.close

      errors = stderr.read.strip
      Honeybadger.notify("Errors importing issue: #{errors}") if errors.present?
    end
  end

  def reindex
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts "indexer -c config/#{Rails.env}.sphinx.conf --rotate entry_delta"
      stdin.close
      errors = stderr.read.strip
      Honeybadger.notify("Errors re-indexing #{errors}") if errors.present?
    end
  end

  def clear_cache
    purge_cache('/')
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

  def update_message(text)
    message = reprocessed_issue.message ? reprocessed_issue.message : ""
    message << "\n- #{text}"
    reprocessed_issue.message = message
    reprocessed_issue.save!
  end

end
