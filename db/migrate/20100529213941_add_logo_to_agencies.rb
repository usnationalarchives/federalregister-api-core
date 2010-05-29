class AddLogoToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :logo_file_name,    :string
    add_column :agencies, :logo_content_type, :string
    add_column :agencies, :logo_file_size,    :integer
    add_column :agencies, :logo_updated_at,   :datetime
  end

  def self.down
    remove_column :agencies, :logo_file_name
    remove_column :agencies, :logo_content_type
    remove_column :agencies, :logo_file_size
    remove_column :agencies, :logo_updated_at
  end
end
