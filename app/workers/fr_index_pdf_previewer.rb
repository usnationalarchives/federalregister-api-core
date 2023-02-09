class FrIndexPdfPreviewer < FrIndexPdfGenerator

  def perform(generated_file_id)
    ActiveRecord::Base.clear_active_connections!
    @generated_file = GeneratedFile.find(generated_file_id)
    @params = generated_file.parameters.symbolize_keys!

    calculate_metadata
    generate_pdf
  end

  private

  def preview?
    false
  end

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
