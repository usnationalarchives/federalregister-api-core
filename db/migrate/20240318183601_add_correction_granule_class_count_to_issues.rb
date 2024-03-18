class AddCorrectionGranuleClassCountToIssues < ActiveRecord::Migration[6.1]
  def change
    change_table(:issues, bulk: true) do |t|
      t.column :correction_granule_class_count, :integer    
      t.column :correction_granule_class_page_count, :integer
    end
  end
end
