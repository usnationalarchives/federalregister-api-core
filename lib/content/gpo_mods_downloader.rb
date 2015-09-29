module Content
  class GpoModsDownloader
    include Content::IssueReprocessorUtils
    @queue = :default

    attr_reader :reprocessed_issue, :date
    DIFF_PREFIXES_TO_REJECT = [
      "<  <identifier type=",
      ">  <identifier type=",
      "<   <searchTitle>",
      ">   <searchTitle>"
    ].map{|prefix| prefix.delete(' ') }

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
      @date = @reprocessed_issue.publication_date
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
      File.open("#{temporary_mods_path}/#{date.to_s(:iso)}.xml", 'w') {|f| f.write(xml) }
    end

    def create_diff
      diff = run_cmd(
          "diff #{temporary_mods_path}/#{date.to_s(:iso)}.xml #{mods_path}/#{date.to_s(:iso)}.xml",
          "ModsDownloader failed to generate diff.",
          :exit_status => [0, 1]
        )
      if diff && diff_from_diffy
        reprocessed_issue.update_attributes(
          :diff => diff,
          :html_diff => diff_from_diffy
        )
      else
        update_status("failed")
      end
    end

    private

    def diff_from_diffy
      @diff_from_diffy ||= CustomDiffy::Diff.new(
        File.join(temporary_mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(mods_path, "#{date.to_s(:iso)}.xml" ),
        :source => 'files',
        :include_plus_and_minus_in_html => true
      ).to_s(:html)
    end

    def format_diff(diff)
      diff.reject do |line|
        DIFF_PREFIXES_TO_REJECT.any?{|prefix| line.delete(' ').start_with? prefix}
      end.
      to_s
    end

  end
end
