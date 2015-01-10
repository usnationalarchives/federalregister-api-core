class Admin::Issues::ApprovalsController < AdminController
  def create
    @issue_approval = IssueApproval.new(:publication_date => params[:issue_id])

    if @issue_approval.save!
      flash[:notice] = "Issue approved! It will appear on the public site in a few minutes"
    else
      flash[:error] = "There was a problem!"
    end
    redirect_to admin_issue_path(params[:issue_id])
  end

  def update
    @issue_approval = IssueApproval.find_by_publication_date!(params[:issue_id])
    @issue_approval.touch(:updated_at)
    redirect_to admin_issue_path(params[:issue_id])
  end
end
