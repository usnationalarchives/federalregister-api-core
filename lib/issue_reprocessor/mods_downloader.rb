require 'ruby-debug'

class IssueReprocessor::ModsDownloader
  attr_reader :reprocessed_issue, :date, :temporary_mods_path

  def initialize(reprocessed_issue_id)
    @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
    @date = @reprocessed_issue.issue.publication_date
    @temporary_mods_path = 'data/mods/tmp'
  end

  def perform
    download
    create_diff
    update_status
  end

  def download
    File.makedirs(temporary_mods_path) #TODO: Troubleshoot permissioning failure.
    mods_text = Net::HTTP.get('gpo.gov', "/fdsys/pkg/FR-#{date.to_s(:iso)}/mods.xml?xxxxx") #TODO: Use timestamp-based cache buster

    File.open("data/mods/tmp/#{date.to_s(:iso)}.xml", 'w') {|f| f.write(mods_text) }
  end

  def create_diff
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts "diff data/mods/tmp/#{date.to_s(:iso)} data/mods/#{date.to_s(:iso)}"
      stdin.close
      if stderr.read.empty?
        reprocessed_issue.update_attributes(:diff => stdout.read.strip)
      else
        #TODO: Implement Honeybadger notify
      end
    end
  end

  def update_status
    reprocessed_issue.update_attributes(:status => "pending_reprocess")
  end

end
