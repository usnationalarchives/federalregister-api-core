class Admin::ReprocessedIssues::DiffsController < AdminController

  def index
    @reprocessed_issue = ReprocessedIssue.find(params[:reprocessed_issue_id])
  end

end
