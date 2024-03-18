class Api::V1::CategoryCountsController < ApiController

  def show
    cache_for 1.hour

    respond_to do |wants|
      wants.csv do
        presenter = IssueReportMonthlyPresenter.new(
          year: nil,
          date_range_type: 'cy',
          custom_date_range: Date.new(2000,1,1)..Date.current
        )
        case params[:id]
        when 'document_type'
          csv_data = presenter.document_type_count_stats
        when 'page_count'
          csv_data = presenter.page_count_stats
        else
          raise NotImplementedError
        end

        send_data CSV.generate{|csv| csv_data.each{|x| csv << x}},
          filename: 'category_statistics.csv',
          type: 'text/csv',
          disposition: 'attachment'
      end
    end
  end

end
