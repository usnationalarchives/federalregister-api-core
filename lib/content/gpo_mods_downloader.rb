module Content
  class GpoModsDownloader
    include Content::IssueReprocessorUtils
    @queue = :default
    attr_reader :reprocessed_issue

    STRINGS_TO_REJECT = [
      "identifier type=",
      "<searchTitle>",
      "lt;mods xmlns"
    ]

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
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
      begin
        diff = FrDiff.new(
          File.join(mods_path, "#{date.to_s(:iso)}.xml"),
          File.join(temporary_mods_path, "#{date.to_s(:iso)}.xml")
        ).diff
        reprocessed_issue.update_attributes(
          :diff => diff,
          :html_diff => html_diff
        )
      rescue FrDiff::CallCommandLineError
        update_status("failed")
        Honeybadger.notify(
          :error_class   => "ModsDownloader failed to generate diff.",
          :error_message => e.message,
          :parameters => {
            :reprocessed_issue_id => reprocessed_issue.id,
            :date => date
          }
        )
      end
    end

    private

    def date
      @date ||= reprocessed_issue.publication_date
    end

    def html_diff
      FrDiff.new(
        File.join(mods_path, "#{date.to_s(:iso)}.xml"),
        File.join(temporary_mods_path, "#{date.to_s(:iso)}.xml"),
        :strings_to_reject => STRINGS_TO_REJECT
      ).html_diff
    end

  end
end
