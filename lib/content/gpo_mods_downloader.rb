module Content
  class GpoModsDownloader
    include Content::IssueReprocessorUtils
    @queue = :api_core

    attr_reader :gpo_path_manager, :path_manager, :reprocessed_issue

    NOISY_MODS_XML_LINES = [
      "identifier type=",
      "<searchTitle>",
      "lt;mods xmlns",
      "url access=",
      "relatedItem type="
    ]

    def initialize(reprocessed_issue_id)
      @reprocessed_issue = ReprocessedIssue.find_by_id(reprocessed_issue_id)
      @path_manager = FileSystemPathManager.new(@reprocessed_issue.issue.publication_date)
      @gpo_path_manager = GpoFilePathManager.new(@reprocessed_issue.issue.publication_date)
    end

    def self.perform(reprocessed_issue_id)
      ActiveRecord::Base.verify_active_connections!

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
      FileUtils.mkdir_p(path_manager.document_temporary_mods_dir)

      url = gpo_path_manager.document_issue_mods_path
      file_path = path_manager.document_temporary_mods_path

      FederalRegisterFileRetriever.download(url, file_path)
    end

    def generate_diffs
      begin
        reprocessed_issue.update_attributes(
          diff: diff[0, 40000],
          html_diff: html_diff[0, 40000]
        )
      rescue FrDiff::CommandLineError
        return false
      end
    end

    private

    def diff
      FrDiff.new(
        path_manager.document_mods_path,
        path_manager.document_temporary_mods_path
      ).diff
    end

    def html_diff
      FrDiff.new(
        path_manager.document_mods_path,
        path_manager.document_temporary_mods_path,
        :ignore => NOISY_MODS_XML_LINES
      ).html_diff
    end

  end
end
