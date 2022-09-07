class AddErrorToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :error, :string
  end
end
