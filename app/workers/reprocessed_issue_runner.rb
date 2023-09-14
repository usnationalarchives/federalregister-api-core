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
    reprocessed_issue.download_mods(async: false) #NOTE: Some MODS in the 1994-2000 eras are likely missing information so we may see some reprocessing errors here
    reprocessed_issue.reprocess_issue(true)
  end

end
