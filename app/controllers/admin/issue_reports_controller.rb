class Admin::IssueReportsController < AdminController
  def index
  end

  def detail
    respond_to do |wants|
      wants.csv do
        year = params[:year].to_i
        headers['Content-Disposition'] = "attachment; filename=\"issue_detail_#{year}.csv\""
        render plain: IssueReportDetailPresenter.new(year: year).as_csv
      end
    end
  end
end