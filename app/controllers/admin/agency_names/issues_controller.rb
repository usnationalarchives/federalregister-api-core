class Admin::AgencyNames::IssuesController < AdminController
  layout 'admin_bootstrap'

  def show
    @presenter = AgencyNameAuditPresenter.new(params[:id])
  end
end
