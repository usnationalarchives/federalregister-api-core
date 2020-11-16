class AddStartPageAndEndPageToIssues < ActiveRecord::Migration[6.0]
  def change
    change_table :issues do |t|
      t.integer :start_page
      t.integer :end_page
    end
  end
end
