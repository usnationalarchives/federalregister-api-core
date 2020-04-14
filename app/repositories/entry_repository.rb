class EntryRepository < BaseRepository
  index_name ['fr-entries', Rails.env].join('-')
  klass Entry


  mapping dynamic: 'strict' do
    indexes :id, {type: 'integer'}
    indexes :title, {
      type:        'text',
      analyzer:    'english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :abstract, {
      type:        'text',
      analyzer:    'english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :full_text, {
      type:        'text',
      analyzer:    'english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :regulation_id_number, {
      type:        'text',
      analyzer:    'english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :docket_id, {
      type:        'text',
      analyzer:    'english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :document_number, {type: 'keyword'}
    indexes :type, {type: 'keyword'}
    indexes :presidential_document_type_id, {type: 'integer'}
    indexes :publication_date_week, {type: 'date'}
    indexes :publication_date_month, {type: 'date'}
    indexes :publication_date_quarter, {type: 'date'}
    indexes :publication_date_year, {type: 'date'}
    indexes :publication_date, {type: 'date'}
    indexes :signing_date, {type: 'date'}
    indexes :president_id, {type: 'integer'}
    indexes :correction, {type: 'boolean'}
    indexes :start_page, {type: 'integer'}
    indexes :executive_order_number, {type: 'keyword'}
    indexes :proclamation_number, {type: 'keyword'}

    # Formerly Sphinx multi-value attributes
    indexes :cfr_affected_parts, {type: 'integer'}
    indexes :agency_ids, {type: 'integer'}
    indexes :topic_ids, {type: 'integer'}
    indexes :section_ids, {type: 'integer'}
    indexes :place_ids, {type: 'integer'}
    indexes :cited_entry_ids, {type: 'integer'}
    indexes :effective_date, {type: 'date'}
    indexes :comment_date, {type: 'date'}
    indexes :accepting_comments_on_regulations_dot_gov, {type: 'boolean'}
    indexes :small_entity_ids, {type: 'integer'}
    indexes :significant, {type: 'boolean'}
  end

  def search_result_klass
    EntrySearchResult
  end

end
