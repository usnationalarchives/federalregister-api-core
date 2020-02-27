class BaseRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  def deserialize(document)
    attributes = document['_source'].merge('highlight' => document['highlight'])

    search_result_klass.new ActiveSupport::HashWithIndifferentAccess.new(attributes).deep_symbolize_keys
  end

end
