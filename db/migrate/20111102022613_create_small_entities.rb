class CreateSmallEntities < ActiveRecord::Migration
  def self.up
    create_table :small_entities do |t|
      t.string :name
    end

    create_table :regulatory_plans_small_entities, :id => false do |t|
      t.integer :regulatory_plan_id
      t.integer :small_entity_id
    end
    add_index :regulatory_plans_small_entities, [:small_entity_id, :regulatory_plan_id]
  end

  def self.down
    drop_table :small_entities
    drop_table :regulatory_plans_small_entities
  end
end
