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
    generated_file.update_attributes(:processing_began_at => Time.now)

    generate_pdf

    generated_file.processing_completed_at = Time.now
    generated_file.save!
  end

  private

  def generate_html
    Content.render_erb("admin/indexes/year.pdf.erb", variables_for_template)
  end

  def variables_for_template
    params = generated_file.parameters.symbolize_keys!

    year = params[:year].to_i

    locals = {}

    locals[:max_date] = params[:max_date] ? Date.parse(params[:max_date]) : Issue.last_issue_date_in_year(year)

    if params[:agency_id]
      agency = Agency.find(params[:agency_id])
      locals[:agency_years] = [FrIndexPresenter::Agency.new(agency, year)]
    else
      locals[:agency_years] = FrIndexPresenter.new(year, :end_date => locals[:end_date])
    end

    locals
  end

  def generate_pdf
    Tempfile.open(['fr_index', '.pdf']) do |output_pdf|
      output_pdf.close

      Tempfile.open(['fr_index', '.html']) do |input_html|
        input_html.write generate_html
        input_html.close

        system("/usr/local/bin/prince #{input_html.path} -o #{output_pdf.path}") or raise 

        attach_file(output_pdf)
      end
    end
  end

  def attach_file(file)
    file.open
    generated_file.attachment = file
    generated_file.attachment_file_type = 'application/pdf'
  end
end