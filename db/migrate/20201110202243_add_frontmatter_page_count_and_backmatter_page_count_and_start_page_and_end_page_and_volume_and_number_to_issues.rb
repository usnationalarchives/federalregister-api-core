class AddFrontmatterPageCountAndBackmatterPageCountAndStartPageAndEndPageAndVolumeAndNumberToIssues < ActiveRecord::Migration[6.0]
  def change
    change_table :issues do |t|
      t.integer :frontmatter_page_count
      t.integer :backmatter_page_count
      t.integer :volume
      t.integer :number
    end
  end
end
