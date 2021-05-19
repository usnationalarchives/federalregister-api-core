class AutomaticModsReprocessor

  AUTOMATED_REPROCESS_USER_ID = 9999
  def self.perform
    if mods_differ?
      reprocessed_issue = ReprocessedIssue.create(
        issue_id: Issue.current.id,
        user_id:  AUTOMATED_REPROCESS_USER_ID
      )
      reprocessed_issue.download_mods(async: false)
      reprocessed_issue.reprocess_issue
    end
  end

  def self.mods_differ?
    path_manager = GpoFilePathManager.new(issue_date)
    mods_differ = false

    Tempfile.create("tmp/automatic_mods_reprocessor_file_#{issue_date.to_s(:iso)}", 'data/') do |f|
      # Download file
      FederalRegisterFileRetriever.download(
        path_manager.document_issue_mods_path,
        f.path
      )

      # Compare file/set reprocess status
      if !FileUtils.compare_file(
        FileSystemPathManager.new(issue_date).document_mods_path,
        f.path
      ) && FrDiff.new(
        # Occasionally a file difference is detected but the diff is empty--adding this as additional redundancy for ensuring an actual change has been identified.
        FileSystemPathManager.new(issue_date).document_mods_path,
        f.path
      ).diff.present?
        mods_differ = true
      end
    end

    mods_differ
  end

  def self.issue_date
    Issue.current.publication_date
  end

end
