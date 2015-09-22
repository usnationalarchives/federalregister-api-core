class IssueReprocessor::ModsDownloader
  @queue = :default

  attr_reader :reprocessed_issue, :date, :temporary_mods_path
  DIFF_PREFIXES_TO_REJECT = [
    "< <name"
  ]

  def initialize(reprocessed_issue_id)
    @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
    @date = @reprocessed_issue.publication_date
    @temporary_mods_path = File.join('data','mods','tmp')
  end

  def self.perform(reprocessed_issue_id)
    new(reprocessed_issue_id).perform
  end

  def perform
    download
    create_diff
    update_status
  end

  def download
    File.makedirs(temporary_mods_path)
    xml = Net::HTTP.get('gpo.gov', "/fdsys/pkg/FR-#{date.to_s(:iso)}/mods.xml?#{Time.now.to_i}")
    File.open("data/mods/tmp/#{date.to_s(:iso)}.xml", 'w') {|f| f.write(xml) }
  end

  def create_diff
    Open4::popen4("sh") do |pid, stdin, stdout, stderr|
      stdin.puts "diff data/mods/tmp/#{date.to_s(:iso)}.xml data/mods/#{date.to_s(:iso)}.xml"
      stdin.close
      errors = stderr.read.strip

      if errors.empty?
        reprocessed_issue.update_attributes(:diff => format_diff(stdout.read.strip) )
      else
        Honeybadger.notify(
          :error_class   => "ModsDownloader failed to generate diff.",
          :error_message => errors
        )
      end
    end
  end

  def update_status
    reprocessed_issue.update_attributes(:status => "pending_reprocess")
  end

  private

  def format_diff(diff)
    diff.reject do |line|
      DIFF_PREFIXES_TO_REJECT.any?{|prefix| line.start_with? prefix}
    end.
    to_s
  end

end
