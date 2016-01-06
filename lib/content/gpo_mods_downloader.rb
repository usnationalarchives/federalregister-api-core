module Content
  class GpoModsDownloader
    include Content::IssueReprocessorUtils
    @queue = :default
    attr_reader :reprocessed_issue

    NOISY_MODS_XML_LINES = [
      "identifier type=",
      "<searchTitle>",
      "lt;mods xmlns",
      "url access=",
      "relatedItem type="
    ]

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
    end

    def self.perform(reprocessed_issue_id)
      new(reprocessed_issue_id).perform
    end

    def perform
      download

      if generate_diffs
        update_status("pending_reprocess")
      else
        update_status("failed")
      end
    end

    def download
      File.makedirs(temporary_mods_path)

      url = "https://www.gpo.gov/fdsys/pkg/FR-#{date.to_s(:iso)}/mods.xml?#{Time.now.to_i}"
      file_path = "#{temporary_mods_path}/#{date.to_s(:iso)}.xml"

      FederalRegisterFileRetriever.download(url, file_path)
    end

    def generate_diffs
      begin
        reprocessed_issue.update_attributes(
          :diff => diff,
          :html_diff => html_diff
        )
      rescue FrDiff::CommandLineError
        return false
      end
    end

    private

    def date
      @date ||= reprocessed_issue.publication_date
    end

    def mods_file_name
      "#{date.to_s(:iso)}.xml"
    end

    def diff
      FrDiff.new(
        File.join(mods_path, mods_file_name),
        File.join(temporary_mods_path, mods_file_name)
      ).diff
    end

    def html_diff
      FrDiff.new(
        File.join(mods_path, mods_file_name),
        File.join(temporary_mods_path, mods_file_name),
        :ignore => NOISY_MODS_XML_LINES
      ).html_diff
    end

  end
end
