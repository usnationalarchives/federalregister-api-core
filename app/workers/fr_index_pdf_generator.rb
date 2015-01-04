class FrIndexPdfGenerator
  attr_reader :params, :generated_file

  def self.perform(*args)
    ActiveRecord::Base.verify_active_connections!
    
    new(*args).perform
  end

  def perform
    generate_pdf
  end

  private

  def generate_html
    Content.render_erb "admin/indexes/year.pdf.erb", 
      :agency_years => agency_years,
      :generated_file => generated_file,
      :fr_index_presenter => fr_index_presenter
  end

  def agency_years
    return @agency_years if @agency_years

    if agency
      @agency_years = [FrIndexPresenter::AgencyPresenter.new(agency, year, :max_date => params[:max_date], :last_published => fr_index_presenter.last_published)]
    else
      @agency_years = fr_index_presenter.agencies_with_pseudonyms
    end
  end

  def agency
    @agency ||= Agency.find(params[:agency_id]) if params[:agency_id]
  end

  def fr_index_presenter
    @fr_index_presenter ||= FrIndexPresenter.new(year, params.slice(:max_date, :last_published))
  end

  def year
    year = params[:year].to_i
  end

  def generate_pdf
    Tempfile.open(['fr_index', '.pdf']) do |output_pdf|
      output_pdf.close

      Tempfile.open(['fr_index', '.html']) do |input_html|
        input_html.write generate_html
        input_html.close

        system("/usr/bin/prince #{input_html.path} -o #{output_pdf.path}") or raise "Unable to generate PDF"

        persist_file(output_pdf)
      end
    end
  end
end
