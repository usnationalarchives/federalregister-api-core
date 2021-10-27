class PublicInspectionDocumentRepository < BaseRepository
  ACTUAL_INDEX_NAME = ['fr-public-inspection-documents', Rails.env].join('-')
  ALIAS_NAME = ['fr-public-inspection-documents-alias', Rails.env].join('-')
  index_name ALIAS_NAME
  klass PublicInspectionDocument

  settings number_of_shards: SETTINGS['elasticsearch']['public_inspection_document_index_shards'], analysis: {
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
    indexes :id, { type: 'integer' }
    indexes :filed_at, { type: 'date' }
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
    indexes :docket_id, { type: 'text', index_options: 'offsets'}
    indexes :document_number, { type: 'keyword' }
    indexes :indexed_at, {type: 'date'}
    indexes :public_inspection_document_id, { type: 'integer' }
    indexes :type, { type: 'keyword' }
    indexes :agency_ids, { type: 'integer' }
    indexes :publication_date, { type: 'date'}
    indexes :raw_text_updated_at, {type: 'date', index: false}
    indexes :special_filing, { type: 'boolean'}
    indexes :public_inspection_issues, { type: 'object' }
  end

  def search_result_klass
    PublicInspectionDocumentSearchResult
  end

end
