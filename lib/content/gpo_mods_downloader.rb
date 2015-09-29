module Content
  class GpoModsDownloader
    include Content::IssueReprocessorUtils
    @queue = :default

    attr_reader :reprocessed_issue, :date, :temporary_mods_path
    DIFF_PREFIXES_TO_REJECT = [
      "<  <identifier type=",
      ">  <identifier type=",
      "<   <searchTitle>",
      ">   <searchTitle>"
    ].map{|prefix| prefix.delete(' ') }

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
      update_status("pending_reprocess")
    end

    def download
      File.makedirs(temporary_mods_path)
      xml = Net::HTTP.get('gpo.gov', "/fdsys/pkg/FR-#{date.to_s(:iso)}/mods.xml?#{Time.now.to_i}")
      File.open("data/mods/tmp/#{date.to_s(:iso)}.xml", 'w') {|f| f.write(xml) }
    end

    def create_diff
      diff = run_cmd(
          "/usr/bin/diff #{Rails.root}/data/mods/tmp/#{date.to_s(:iso)}.xml #{Rails.root}/data/mods/#{date.to_s(:iso)}.xml",
          "ModsDownloader failed to generate diff.",
          :exit_status => [0, 1]
        )
      if diff
        reprocessed_issue.update_attribute(:diff, diff)
      else
        update_status("failed")
      end
    end

    private

    def format_diff(diff)
      diff.reject do |line|
        DIFF_PREFIXES_TO_REJECT.any?{|prefix| line.delete(' ').start_with? prefix}
      end.
      to_s
    end

  end
end
