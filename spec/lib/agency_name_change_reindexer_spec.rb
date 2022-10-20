require 'spec_helper'
require 'sidekiq/testing'

describe AgencyNameChangeReindexer do

  it "reindexes as expected when assigning an agency to an agency name that lacks one" do
    allow_any_instance_of(AgencyName).to receive(:recompile_associated_tables_of_contents)

    Sidekiq::Testing.inline! do
      # Create entries associated with an agency name
      agency_name = Factory(:agency_name, agency: nil)
      entry = Factory(:entry, agency_name_ids: [agency_name.id])
      Entry.bulk_index([entry], refresh: true)
      expect($entry_repository.find(entry.id).agency_ids).to eq([])

      # Change the agency name (simulating a change via admin interface)
      agency = Factory(:agency)
      agency_name.update!(agency_id: agency.id)

      # confirm the es agency is valid
      result = $entry_repository.find(entry.id).agency_ids
      expect(result).to eq([agency.id])
    end
  end

  it "reindexes as expected when changing an agency assignment's ageny to a different agency" do
    allow_any_instance_of(AgencyName).to receive(:recompile_associated_tables_of_contents)

    Sidekiq::Testing.inline! do
      # Create entries associated with an agency name
      agency_1 = Factory(:agency)
      agency_name_1 = Factory(:agency_name, agency: agency_1)
      entry = Factory(:entry, agency_name_ids: [agency_name_1.id])
      Entry.bulk_index([entry], refresh: true)
      expect($entry_repository.find(entry.id).agency_ids).to eq([agency_1.id])

      # Change the agency name (simulating a change via admin interface)
      agency_2 = Factory(:agency)
      agency_name_1.update!(agency_id: agency_2.id)

      # confirm the es agency is valid
      result = $entry_repository.find(entry.id).agency_ids
      expect(result).to eq([agency_2.id])
    end
  end

end
