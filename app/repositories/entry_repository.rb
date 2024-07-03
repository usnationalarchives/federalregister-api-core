class EntryRepository < BaseRepository
  index_name [
    'fr-entries',
    (Rails.env.test? ? "test#{((ENV['TEST_ENV_NUMBER'] == "1") ? "" : ENV['TEST_ENV_NUMBER'])}" : Rails.env),
    Settings.container.deployment_environment
  ].compact.join('-')
  klass Entry

  settings number_of_shards: Settings.elasticsearch.entry_index_shards, knn: true, analysis: {
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
      },
      "edge_ngram_filter": {
        "type": "edge_ngram",
        "min_gram": 1,
        "max_gram": 20
      }
    },
    "analyzer": {
      "autocomplete": {
        "type": "custom",
        "tokenizer": "standard",
        "filter": [
          "lowercase",
          "edge_ngram_filter"
        ]
      },
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
    indexes :search_term_completion, {
      type: "text",
      analyzer: "autocomplete",
      search_analyzer: "standard",
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
    indexes :dockets, {
      type: 'object',
      enabled: false
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
    if Settings.feature_flags.open_search_version_supports_vectors
    indexes :full_text_chunk_embedding, {
      type: 'nested',
      properties: {
        knn: {
          type: "knn_vector",
          dimension: 768,
          method: {
            engine: "lucene", #Evaluated against NMSLIB and FAISS and lucene since it prioritizes seamless integration over speed.  Supposedly good for datasets that contain < 10M vectors.  As our comfort and scale grows, we may want to consider moving to NMSLIB or FAISS.
            space_type: "cosinesimil", # The method used to compare vector proximity.  Evaluated against inner product and went with cosine similarity since it emphasizes vector direction more than vector magnitude and is a good fit for semantic search.
            name: "hnsw", # Hierarchical Navigable Small Worlds.  Defines the algorithm for vector space traversal.  Traversal starts at a coarse level and traverses through finer and finer levels to identify the closest neighbor.
            parameters: {}
          }
        }
      }
      # FUTURE ITEMS:
      # 1. We may want to consider storing the source full_text_chunks so we can surface them to the user accordingly
      # 2. If we continue to use the Lucene engine, we may want to investigate storing vectors as byte vectors in lieu of float vectors.  Open Search documentation states: "In k-NN benchmarking tests, the use of byte rather than float vectors resulted in a significant reduction in storage and memory usage as well as improved indexing throughput and reduced query latency. Additionally, precision on recall was not greatly affected (note that recall can depend on various factors, such as the quantization technique and data distribution)."
      # See https://opensearch.org/docs/latest/field-types/supported-field-types/knn-vector/
    }
    end
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
    indexes :images_metadata, {
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
    indexes :notice_type_id, {type: 'integer'}
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
    indexes :sorn_system_name, {type: 'keyword', index: false}
    indexes :sorn_system_number, {type: 'keyword', index: false}
    indexes :start_page, {type: 'integer'}
    indexes :topics, {type: 'keyword', index: false}
    indexes :subtype, {type: 'keyword', index: false}
    indexes :executive_order_number, {type: 'keyword'}
    indexes :not_received_for_publication, {type: 'boolean'}
    indexes :proclamation_number, {type: 'keyword'}

    # Formerly Sphinx multi-value attributes
    indexes :cfr_affected_parts, {type: 'integer'}
    indexes :agency_name_ids, {type: 'integer'}
    indexes :agency_ids, { type: 'integer' }
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
    EsEntrySearchResult
  end

end
