class EntryRepository < BaseRepository
  index_name ['fr-entries', Rails.env, SETTINGS['elasticsearch']['deployment_environment']].compact.join('-')
  klass Entry

  settings number_of_shards: SETTINGS['elasticsearch']['entry_index_shards'], analysis: {
    # Create custom analyzer based on default english analyzer
    # swap in KStem stemmer instead of Porter
    "filter": {
      "english_stop": {
        "type":       "stop",
        "stopwords":  "_english_"
      },
      "english_stemmer": {
        "type":       "stemmer",
        "language":   "light_english"
      },
      "english_possessive_stemmer": {
        "type":       "stemmer",
        "language":   "possessive_english"
      }
    },
    "analyzer": {
      "custom_english": {
        "tokenizer":  "standard",
        "filter": [
          "english_possessive_stemmer",
          "lowercase",
          "english_stop",
          "english_stemmer"
        ]
      }
    }
  }

  mapping dynamic: 'strict' do
    indexes :id, {type: 'integer'}
    indexes :title, {
      type:        'text',
      analyzer:    'custom_english',
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
      analyzer:    'custom_english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :action, {
      type: 'keyword',
      index: false,
    }
    indexes :agencies, {
      type:        'object',
      enabled:      false,
    }
    indexes :body_html_url, {
      type: 'keyword',
      index: false,
    }
    indexes :citation, {
      type: 'keyword',
      index: false,
    }
    indexes :comments_close_on, {
      type: 'date',
      index: false,
    }
    indexes :comment_url, {
      type:        'keyword',
      index:      false,
    }
    indexes :cfr_references, {
      type:        'object',
      enabled:      false,
    }
    indexes :agency_names, {
      type:        'keyword',
      index:       false
    }
    indexes :dates, {
      type: 'text',
      index: false
    }
    indexes :disposition_notes, {
      type: 'text',
      index: false
    }
    indexes :effective_on, {
      type: 'date',
      index: false
    }
    indexes :end_page, {
      type: 'integer',
    }
    indexes :executive_order_notes, {
      type: 'text',
      index: false
    }
    indexes :full_text, {
      type:        'text',
      analyzer:    'custom_english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :full_text_xml_url, {
      type: 'keyword',
      index: false
    }
    indexes :html_url, {
      type: 'keyword',
      index: false
    }
    indexes :images, {
      type: 'object',
      enabled: false
    }
    indexes :json_url, {
      type: 'keyword',
      index: false
    }
    indexes :mods_url, {
      type: 'keyword',
      index: false
    }
    indexes :page_length, {
      type: 'integer',
      index: false
    }
    indexes :pdf_url, {
      type: 'keyword',
      index: false
    }
    indexes :president, {
      type: 'object',
      enabled: false
    }
    indexes :raw_text_url, {
      type: 'keyword',
      index: false
    }
    indexes :public_inspection_pdf_url, {
      type: 'keyword',
      index: false
    }
    indexes :regulations_dot_gov_info, {
      type: 'object',
      enabled: false
    }


    indexes :regulation_id_number, {
      type:        'text',
      analyzer:    'custom_english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :regulation_id_numbers, {
      type: 'keyword',
      index: false
    }
    indexes :regulation_id_number_info, {
      type: 'object',
      enabled: false
    }
    indexes :docket_id, {
      type:        'text',
      analyzer:    'custom_english',
      term_vector: 'with_positions_offsets',
      fields: {
        exact: {
          type:        'text',
          analyzer:    'standard',
          term_vector: 'with_positions_offsets'
        }
      }
    }
    indexes :entry_type, {
      type: 'keyword',
      index: false
    }
    indexes :raw_text_updated_at, {type: 'date', index: false}
    indexes :regulations_dot_gov_url, {
      type: 'keyword',
      index: false
    }
    indexes :document_number, {type: 'keyword'}
    indexes :indexed_at, {type: 'date'}
    indexes :toc_doc, {type: 'text', index: false}
    indexes :toc_subject, {type: 'text', index: false}
    indexes :type, {type: 'keyword'}
    indexes :presidential_document_type_id, {type: 'integer'}
    indexes :presidential_document_number, {type: 'keyword', index: false}
    indexes :publication_date_week, {type: 'date'}
    indexes :publication_date_month, {type: 'date'}
    indexes :publication_date_quarter, {type: 'date'}
    indexes :publication_date_year, {type: 'date'}
    indexes :publication_date, {type: 'date'}
    indexes :signing_date, {type: 'date'}
    indexes :president_id, {type: 'integer'}
    indexes :correction, {type: 'boolean'}
    indexes :correction_of, {type: 'keyword', index: false}
    indexes :corrections, {type: 'keyword', index: true}
    indexes :start_page, {type: 'integer'}
    indexes :topics, {type: 'keyword', index: false}
    indexes :subtype, {type: 'keyword', index: false}
    indexes :executive_order_number, {type: 'integer'}
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
    indexes :volume, {type: 'integer'}
  end

  def search_result_klass
    if SETTINGS['elasticsearch']['active_record_based_retrieval']
      EntrySearchResult
    else
      EsEntrySearchResult
    end
  end

end
