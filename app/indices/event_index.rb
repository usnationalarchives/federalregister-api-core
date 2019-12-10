ThinkingSphinx::Index.define :event, :with => :active_record, :delta => ThinkingSphinx::Deltas::ManualDelta do
  # fields
  indexes "entries.title", :as => :title
  indexes entry.abstract
  indexes place.name, :as => :place
  indexes event_type, :as => :type, :facet => true
#   indexes "CONCAT('#{entries.document_path}/full_text/raw/', entries.document_file_path, '.txt')", :as => :entry_full_text, :file => true

  # attributes
  has date
  # has entry.agency_assignments(:agency_id), :as => :agency_ids
  has place_id

  set_property :field_weights => {
    "title" => 100,
    "place" => 50,
    "abstract" => 50,
    "full_text" => 25,
  }
  where "events.date BETWEEN DATE_SUB(NOW(), INTERVAL 1 MONTH) AND DATE_ADD(NOW(), INTERVAL 2 YEAR) AND event_type != 'RegulationsDotGovCommentsCloseDate'"

  # this line must appear after the define_index block
  # include ThinkingSphinx::Deltas::ManualDelta::ActiveRecord
end
