class RenameEntryCfrAffectedParts < ActiveRecord::Migration
  def self.up
    rename_table :entry_cfr_affected_parts, :entry_cfr_references
  end

  def self.down
    rename_table :entry_cfr_references, :entry_cfr_affected_parts
  end
end
