class Admin::IssuesController < AdminController
  def index
    @issues = Issue.most_recent(50)
  end

  def show
    @current_issue = @approved_issue = Issue.find_by_publication_date(params[:id])
    @publication_date = Date.parse(params[:id])
    @entries_without_sections = Entry.
      published_on(@publication_date).
      includes(:section_assignments).
      where("section_assignments.id IS NULL").
      references(:section_assignments)
    @sections = Section.all
    @issue_approval = IssueApproval.find_by_publication_date(@publication_date)
  end

  def preview
    @sections = Section.all
    @current_issue = @approved_issue = Issue.find_by_publication_date(params[:id])
    @preview = true
    @faux_controller = "special"
    @faux_action = "home"
    render :template => "special/home", :layout => 'application'
  end
end
