require 'spec_helper'

describe EntryRepository do
  before(:each) do
    $entry_repository.create_index!(force: true)
  end

  it "creates an index with the appropriate mappings" do
    pending("Enable once new FVF mapping is confirmed as working")
    expected_mappings = {
      dynamic: "strict",
      properties: {
        docket_id: {
          type: "text",
          index_options: "offsets",
          analyzer: "english",
          fields: {
            exact: {
              analyzer: "standard",
              type: "text"
            }
          }
        },
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
        executive_order_number: {type: 'integer'},
        proclamation_number: {type: 'keyword'},
        small_entity_ids: {type: 'integer'},
        title: {
          type: "text",
          index_options: "offsets",
          analyzer: "english",
          fields: {
            exact: {
              analyzer: "standard",
              type: "text"
            }
          }
        },
        full_text: {
          type: "text",
          index_options: "offsets",
          analyzer: "english",
          fields: {
            exact: {
              analyzer: "standard",
              type: "text"
            }
          }
        },
        id: {type: 'integer'},
        regulation_id_number: {
          type: "text",
          index_options: "offsets",
          analyzer: "english",
          fields: {
            exact: {
              analyzer: "standard",
              type: "text"
            }
          }
        },
        abstract: {
          type: "text",
          index_options: "offsets",
          analyzer: "english",
          fields: {
            exact: {
              analyzer: "standard",
              type: "text"
            }
          }
        },

        # Formerly Sphinx multi-value attributes
        accepting_comments_on_regulations_dot_gov: {type: 'boolean'},
        agency_ids: {type: 'integer'},
        cfr_affected_parts: {type: 'integer'},
        cited_entry_ids: {type: 'integer'},
        comment_date: {type: 'date'},
        effective_date: {type: 'date'},
        place_ids: {type: 'integer'},
        section_ids: {type: 'integer'},
        significant: {type: 'boolean'},
        topic_ids: {type: 'integer'}
      }
    }

    expect($entry_repository.mappings.to_hash[:dynamic]).to eq expected_mappings[:dynamic]
    expect($entry_repository.mappings.to_hash[:properties]).to eq expected_mappings[:properties]
  end

end
