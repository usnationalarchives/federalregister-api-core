class AddRelevanceScoreToPlaceDeterminations < ActiveRecord::Migration
  def self.up
    add_column :place_determinations, :relevance_score, :float
  end

  def self.down
    remove_column :place_determinations, :relevance_score
  end
end
