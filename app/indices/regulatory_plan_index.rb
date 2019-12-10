ThinkingSphinx::Index.define :regulatory_plan, :with => :active_record, :delta => ThinkingSphinx::Deltas::ManualDelta do
  # Will require a index rebuild when new regulatory plan issue comes in...
  where "regulatory_plans.issue = '#{RegulatoryPlan.current_issue}'"

  # fields
  indexes title
  indexes abstract
  indexes "CONCAT('#{FileSystemPathManager.data_file_path}/regulatory_plans/', issue, '/', regulation_id_number, '.xml')", :as => :full_text, :file => true
  indexes priority_category, :facet => true

  # attributes
  has agency_assignments(:agency_id), :as => :agency_ids

  set_property :field_weights => {
    "title" => 100,
    "abstract" => 50,
    "full_text" => 25,
  }

  # this line must appear after the define_index block
  # include ThinkingSphinx::Deltas::ManualDelta::ActiveRecord
end
