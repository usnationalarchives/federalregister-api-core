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
          filename = "federal_register_document_type_published_per_category.csv"
          csv_data = presenter.document_type_count_stats
        when 'page_count'
          filename = "federal_register_page_count_published_per_category.csv"
          csv_data = presenter.page_count_stats
        else
          raise NotImplementedError
        end

        # NOTE: It was necessary to generate the CSV awkwardly in lieu of generating it in-memory via CSV.generate because Excel was not registering the footnote dagger characters properly by default unless a BOM and open mode were specified when creating the file
        bom           = "\xEF\xBB\xBF"
        in_memory_csv = CSV.generate(encoding: 'UTF-8') {|csv| csv_data << [bom]; csv_data.each{|x| csv << x}}
        open_mode     = 'w+:UTF-8'
        file_path     = "data/#{filename}"
        File.open(file_path, open_mode) do |f|
          f.write bom
          f.write(in_memory_csv)
        end
        send_file(
          file_path,
          filename:    File.basename(file_path), 
          disposition: 'attachment'
        )

      end
    end
  end

end
