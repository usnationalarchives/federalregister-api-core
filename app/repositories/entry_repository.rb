class EntryRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name ['fr-entries', Rails.env].join('-')

  mapping dynamic: 'strict' do
    indexes :docket_id, {type: 'keyword'}
    indexes :document_number, {type: 'keyword'}
    indexes :type, {type: 'keyword'} #TODO: May be an ES keyword
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
    indexes :significant, {type: 'boolean'}
  end

  def wrap_search(term, query={})
    SearchResultsWrapper.new( search(query) )
  end

  class SearchResultsWrapper
    delegate_missing_to :@es_result

    # This class is being used to imitate the Sphinx results as we set up ES
    def initialize(es_result)
      @es_result = es_result
    end

    def total_pages
      0 #TODO: Fix
    end

    def count
      es_result.total
    end

    private

    attr_reader :es_result

  end

end
