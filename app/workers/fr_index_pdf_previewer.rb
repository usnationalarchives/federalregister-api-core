class FrIndexPdfPreviewer < FrIndexPdfGenerator
  @queue = :fr_index_pdf_previewer

  def initialize(generated_file_id)
    @generated_file = GeneratedFile.find(generated_file_id)
    @params = generated_file.parameters.symbolize_keys!
  end

  def perform
    calculate_metadata
    super
  end

  private

  def calculate_metadata
    generated_file.processing_began_at = Time.now
    generated_file.processing_completed_at = nil
    generated_file.total_document_count = agency_years.sum(&:entry_count)
    generated_file.processed_document_count = 0
    generated_file.save!
  end

  def persist_file(file)
    file.open
    generated_file.attachment = file
    generated_file.attachment_file_type = 'application/pdf'
    generated_file.processing_completed_at = Time.now
    generated_file.save!
  end
end
