class PublicInspectionDocumentRepository < BaseRepository
  index_name ['fr-public-inspection-documents', Rails.env].join('-') #TODO make dynamic with: Settings.deployment_environment
  klass PublicInspectionDocument

  mapping dynamic: 'strict' do
    indexes :id, { type: 'integer' }
    indexes :filed_at, { type: 'date' }
    indexes :title, { type: 'text'}
    indexes :full_text, { type: 'text'}
    indexes :docket_id, { type: 'keyword'}
    indexes :document_number, { type: 'keyword' }
    indexes :public_inspection_document_id, { type: 'integer' }
    indexes :type, { type: 'keyword' } #TODO: type may be a reserved word
    indexes :agency_ids, { type: 'integer' }
    indexes :publication_date, { type: 'date'}
    indexes :special_filing, { type: 'boolean'}
    indexes :docket_numbers, { type: 'object' } # Maybe integer array
    indexes :public_inspection_issues, { type: 'object' }
  end

  def wrap_search(term, query={})
    SearchWrapper.new(search(query))
  end

  #TODO: Rename to SearchCollectionWrapper to be more explicit
  class SearchWrapper
    # This class is being used to imitate the Sphinx results as we set up ES
    attr_reader :es_result #TODO: Make private

    def initialize(es_result)
      @es_result = es_result
    end

    def total_pages
      0 # FIX
    end

    def count
      es_result.total
    end
  end

  def search_result_klass
    PublicInspectionDocumentSearchResult
  end

end
