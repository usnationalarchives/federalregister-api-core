class FrIndexPdfGenerator
  @queue = :fr_index

  def self.perform(generated_file_id)
    ActiveRecord::Base.verify_active_connections!
    
    new(generated_file_id).perform
  end

  attr_reader :generated_file

  def initialize(generated_file_id)
    @generated_file = GeneratedFile.find(generated_file_id)
  end

  def perform
    calculate_metadata
    generate_pdf
  end

  private

  def calculate_metadata
    generated_file.processing_began_at = Time.now
    generated_file.processing_completed_at = nil
    generated_file.total_document_count = agency_years.sum(&:entry_count)
    generated_file.processed_document_count = 0
    generated_file.save!
  end

  def generate_html
    Content.render_erb "admin/indexes/year.pdf.erb", 
      :agency_years => agency_years,
      :generated_file => generated_file
  end

  def agency_years
    return @agency_years if @agency_years

    year = params[:year].to_i

    if params[:agency_id]
      agency = Agency.find(params[:agency_id])
      @agency_years = [FrIndexPresenter::Agency.new(agency, year, :max_date => params[:max_date])]
    else
      @agency_years = FrIndexPresenter.new(year, :max_date => params[:max_date]).agencies
    end
  end

  def params
    @params ||= generated_file.parameters.symbolize_keys!
  end

  def generate_pdf
    Tempfile.open(['fr_index', '.pdf']) do |output_pdf|
      output_pdf.close

      Tempfile.open(['fr_index', '.html']) do |input_html|
        input_html.write generate_html
        input_html.close

        system("/usr/local/bin/prince #{input_html.path} -o #{output_pdf.path}") or raise "Unable to generate PDF"

        attach_file(output_pdf)
      end
    end
  end

  def attach_file(file)
    file.open
    generated_file.attachment = file
    generated_file.attachment_file_type = 'application/pdf'
    generated_file.processing_completed_at = Time.now
    generated_file.save!
  end
end