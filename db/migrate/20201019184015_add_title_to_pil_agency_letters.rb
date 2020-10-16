class AddTitleToPilAgencyLetters < ActiveRecord::Migration[6.0]
  def change
    add_column :pil_agency_letters, :title, :string
  end
end
