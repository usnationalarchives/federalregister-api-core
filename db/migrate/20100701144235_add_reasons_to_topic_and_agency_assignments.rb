class AddReasonsToTopicAndAgencyAssignments < ActiveRecord::Migration
  def self.up
    add_column :topic_assignments, :topics_topic_name_id, :integer
    add_column :agency_assignments, :agency_name_id, :integer

    add_index :topic_assignments, :topics_topic_name_id
    add_index :agency_assignments, :agency_name_id
  end

  def self.down
    remove_column :agency_assignments, :agency_name_id
    remove_column :topic_assignments, :topics_topic_name_id
  end
end
