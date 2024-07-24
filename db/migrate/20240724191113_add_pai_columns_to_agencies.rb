class AddPaiColumnsToAgencies < ActiveRecord::Migration[6.1]
  def change
    change_table(:agencies, bulk: true) do |t|
      t.column :pai_identifier, :string
      t.column :pai_year, :integer
    end
  end
end
