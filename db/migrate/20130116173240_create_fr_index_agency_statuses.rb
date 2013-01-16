class CreateFrIndexAgencyStatuses < ActiveRecord::Migration
  def self.up
    create_table :fr_index_agency_statuses do |t|
      t.integer :year
      t.integer :agency_id
      t.datetime :last_completed_at
      t.integer :needs_attention_count
    end

    add_index :fr_index_agency_statuses, [:year, :agency_id]
  end

  def self.down
    drop_table :fr_index_agency_statuses
  end
end
