# == Schema Information
#
# Table name: generated_files
#
#  id                       :integer(4)      not null, primary key
#  parameters               :string(255)
#  token                    :string(255)
#  processing_began_at      :datetime
#  processing_completed_at  :datetime
#  attachment_file_name     :string(255)
#  attachment_file_type     :string(255)
#  attachment_file_size     :integer(4)
#  attachment_updated_at    :datetime
#  creator_id               :integer(4)
#  updater_id               :integer(4)
#  created_at               :datetime
#  updated_at               :datetime
#  total_document_count     :integer(4)
#  processed_document_count :integer(4)
#

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
