class EntryRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name ['fr-entries', Rails.env].join('-')

  mapping dynamic: 'strict' do
    indexes :id, {type: 'integer'}
    indexes :title, { type: 'text'}
    indexes :abstract, { type: 'text'}
    indexes :full_text, { type: 'text'}
    indexes :regulation_id_number, { type: 'keyword'}
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
    indexes :topic_ids, {type: 'integer'}
    indexes :section_ids, {type: 'integer'}


    indexes :significant, {type: 'boolean'}
  end

end
