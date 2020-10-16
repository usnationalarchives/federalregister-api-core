class AddAttachmentFileToPilAgencyLetters < ActiveRecord::Migration[6.0]
  def self.up
    change_table :pil_agency_letters do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :pil_agency_letters, :file
  end
end
