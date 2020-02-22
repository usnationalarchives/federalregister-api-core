require 'spec_helper'

describe EntryRepository do
  it "creates an index with the appropriate mappings" do
    pending('update mappings')
    expected_mappings = {
      dynamic: "strict",
      properties: {
        #TODO: Add attributes

        docket_id: {type: 'keyword'},
        document_number: {type: 'keyword'},
        type: {type: 'keyword'},
        presidential_document_type_id: {type: 'integer'},
        publication_date_week: {type: 'date'},
        publication_date_month: {type: 'date'},
        publication_date_quarter: {type: 'date'},
        publication_date_year: {type: 'date'},
        publication_date: {type: 'date'},
        signing_date: {type: 'date'},
        president_id: {type: 'integer'},
        correction: {type: 'boolean'},
        start_page: {type: 'integer'},
        executive_order_number: {type: 'keyword'},
        proclamation_number: {type: 'keyword'},

        # Formerly Sphinx multi-value attributes
        cfr_affected_parts: {type: 'integer'},
        agency_ids: {type: 'integer'},
        significant: {type: 'boolean'},
      }
    }

    expect($entry_repository.mappings.to_hash).to eq expected_mappings
  end

end
