class AddIndexesToRegulatoryPlansSmallEntities < ActiveRecord::Migration
  def self.up
    add_index :regulatory_plans_small_entities, [:regulatory_plan_id, :small_entity_id], :name => "reg_then_entity"
  end

  def self.down
    remove_index :regulatory_plans_small_entities, [:regulatory_plan_id, :small_entity_id], :name => "reg_then_entity"
  end
end
