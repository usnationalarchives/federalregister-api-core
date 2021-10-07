class BaseRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  def deserialize(document)
    attributes = document['_source'].merge('highlight' => document['highlight'])

    pub_date = attributes['publication_date']
    if pub_date
      attributes['publication_date'] = Date.parse(pub_date)
    end

    EsEntrySearchResult.new ActiveSupport::HashWithIndifferentAccess.new(attributes).deep_symbolize_keys
  end

  def update_mapping!
    client.indices.put_mapping index: index_name,
      body: mappings.to_hash
  end
end
