class Admin::AgencyNames::IssuesController < AdminController
  def show
    @presenter = AgencyNameAuditPresenter.new(params[:id])
  end
end
