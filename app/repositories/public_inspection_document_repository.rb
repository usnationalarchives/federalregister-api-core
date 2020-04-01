class PublicInspectionDocumentRepository < BaseRepository
  index_name ['fr-public-inspection-documents', Rails.env].join('-') #TODO make dynamic with: Settings.deployment_environment
  klass PublicInspectionDocument

  mapping dynamic: 'strict' do
    indexes :id, { type: 'integer' }
    indexes :filed_at, { type: 'date' }
    indexes :title, {
      type: 'text',
      index_options: 'offsets',
      analyzer: 'english',
      fields: {
        exact: {
          type: 'text',
          analyzer: 'standard'
        }
      }
    }
    indexes :full_text, {
      type: 'text',
      index_options: 'offsets',
      analyzer: 'english',
      fields: {
        exact: {
          type: 'text',
          analyzer: 'standard'
        }
      }
    }
    indexes :docket_id, { type: 'text', index_options: 'offsets'}
    indexes :document_number, { type: 'keyword' }
    indexes :public_inspection_document_id, { type: 'integer' }
    indexes :type, { type: 'keyword' }
    indexes :agency_ids, { type: 'integer' }
    indexes :publication_date, { type: 'date'}
    indexes :special_filing, { type: 'boolean'}
    indexes :public_inspection_issues, { type: 'object' }
  end

  def search_result_klass
    PublicInspectionDocumentSearchResult
  end

end
