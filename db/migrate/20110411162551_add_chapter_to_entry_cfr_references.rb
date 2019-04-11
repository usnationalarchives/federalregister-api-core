class AddChapterToEntryCfrReferences < ActiveRecord::Migration
  def self.up
    add_column :entry_cfr_references, :chapter, :integer
  end

  def self.down
    remove_column :entry_cfr_references, :chapter
  end
end
