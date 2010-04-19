class CreateRegulatoryPlans < ActiveRecord::Migration
  def self.up
    create_table :regulatory_plans do |t|
      t.string :regulation_id_number
      t.string :issue
      
      t.text :title
      t.text :abstract
      t.string :priority_category
    end
    
    add_index :regulatory_plans, [:regulation_id_number, :issue]
    
    create_table :regulatory_plan_events do |t|
      t.integer :regulatory_plan_id
      t.string :date
      t.string :action
      t.string :fr_citation
    end
    
    add_index :regulatory_plan_events, :regulatory_plan_id
  end

  def self.down
    drop_table :regulatory_plan_events
    drop_table :regulatory_plans
  end
end
