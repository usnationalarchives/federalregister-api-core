class GeneratedFile < ApplicationModel
  serialize :parameters
  has_attached_file :attachment,
    :path => "public/generated_files/fr_index/:creation_year/:creation_month/:token/file.:extension",
    :url => "/generated_files/fr_index/:creation_year/:creation_month/:token/file.:extension"

  before_create :generate_token

  def increment_processed_processed_document_count_by(count)
    self.processed_document_count += count
    save!
  end

  def percentage_complete
    if total_document_count
      processed_document_count.to_f / total_document_count
    end
  end

  def estimated_processing_remaining
    if processing_began_at && percentage_complete && percentage_complete > 0
      time_elapsed = (Time.now - processing_began_at).to_i
      time_elapsed - (time_elapsed.to_f / percentage_complete)
    end
  end

  private

  def generate_token
    self.token = SecureRandom.hex(20)
  end
end
