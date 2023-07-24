class ReprocessedIssueRunner
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(publication_date)
    date = publication_date.is_a?(Date) ? publication_date : Date.parse(publication_date)
    issue = Issue.find_by_publication_date!(date)
    reprocessed_issue = ReprocessedIssue.create(
      issue_id: issue.id,
      user_id:  AutomaticModsReprocessor::AUTOMATED_REPROCESS_USER_ID
    )
    if date >= Date.new(2000,1,1)
      # Try to reimport MODS only if MODS greater than 2000 since MODS in the 1994-2000 eras are missing information
      reprocessed_issue.download_mods(async: false)
    end
    reprocessed_issue.reprocess_issue
  end

end
