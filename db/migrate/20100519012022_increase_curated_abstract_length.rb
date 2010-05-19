class IncreaseCuratedAbstractLength < ActiveRecord::Migration
  def self.up
    change_column :entries, :curated_abstract, :string, :length => 500
  end

  def self.down
    change_column :entries, :curated_abstract, :string, :length => 255
  end
end
