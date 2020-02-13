class PublicInspectionDocumentRepository
  include Elasticsearch::Persistence::Repository
  include Elasticsearch::Persistence::Repository::DSL

  index_name ['fr-search', Rails.env].join('-') #TODO make dynamic with: Settings.deployment_environment
  klass PublicInspectionDocument

  mapping dynamic: 'strict' do
  #   indexes :filed_at, { type: 'date' }
    indexes :title, { type: 'text'}
  #   indexes :full_text, { type: 'text'}
  #   indexes :docket_id, { type: 'keyword'}
  #   indexes :document_number, { type: '?'}
  #   indexes :public_inspection_document_id, { type: '?'}
  #   indexes :type, { type: '?'} #TODO: type may be a reserved word
    indexes :agency_ids, { type: 'integer' }
    indexes :publication_date, { type: 'date'}
  #   indexes :filed_at, { type: '?'}
    indexes :special_filing, { type: 'boolean'}
  #   indexes :docket_numbers, { type: '?'}
  #   indexes :public_inspection_issues, { type: '?'}
  end

  def search_wrapper(term, query={})
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

  # def serialize(document)
  # end

  # def deserialize(doc)
  # end
end










# SAMPLE INDEX

# class ContentVersionRepository
#   include Elasticsearch::Persistence::Repository
#   include Elasticsearch::Persistence::Repository::DSL

#   index_name ['ecfr-search', Settings.deployment_environment].join('-')
#   klass ContentVersion

#   mapping dynamic: 'strict' do
#     indexes :starts_on, { type: 'date' }
#     indexes :ends_on, { type: 'date' }
#     indexes :substantive_change_received_on, { type: 'date' }

#     indexes :content_type, { type: 'keyword' }

#     indexes :hierarchy, {
#       type: 'object',
#       properties: ContentVersion::LEVELS.each_with_object({}) {|level, hsh| hsh[level] = {type: 'keyword', null_value: ''}}
#     }

#     indexes :headings, {
#       type: 'object',
#       properties: ContentVersion::LEVELS.each_with_object({}) {|level, hsh| hsh[level] = {type: 'text', analyzer: 'english'}}
#     }

#     indexes :hierarchy_headings, {
#       type: 'object',
#       properties: ContentVersion::LEVELS.each_with_object({}) {|level, hsh| hsh[level] = {type: 'text', index: false}}
#     }

#     indexes :structure_id, {
#       type: 'keyword',
#     }

#     indexes :full_text, { analyzer: 'english' }

#     indexes :removed
#     indexes :reserved
#     indexes :structure_index
#   end

#   def serialize(document)
#     document.set_id
#     document
#   end

#   def deserialize(document)
#     content_version = super
#     content_version.set_id
#     content_version
#   end

#   def delete_all
#     delete_by_query(match_all: {})
#   end

#   def delete_by_query(params)
#     client.delete_by_query index: index_name,
#       body: {
#         query: params,
#       },
#       refresh: by_query_refresh_strategy
#   end

#   def refresh_index
#     refresh_index!
#   end

#   def update_by_query(script, query)
#     client.update_by_query index: index_name,
#       body: {
#         script: { inline: script },
#         query: query
#       },
#       refresh: by_query_refresh_strategy
#   end

#   def create_index(options={})
#     client.indices.delete index: index_name rescue nil if options[:force]

#     unless client.indices.exists? index: index_name
#       client.indices.create index: index_name,
#         body: {
#           settings: settings.to_hash,
#           mappings: mappings.to_hash
#         }
#     end
#   end

#   def copy_index(source_index:, destination_index:)
#     client.reindex body: {
#       source: { index: source_index },
#       dest: { index: destination_index }
#     },
#     wait_for_completion: false
#   end

#   def update_mapping
#     client.indices.put_mapping index: index_name,
#       type: document_type,
#       body: mappings.to_hash
#   end

#   def fetch(date:, hierarchy:)
#     conditions = hierarchy.es_conditions
#     conditions += [
#       { range: { starts_on: { lte: date }}},
#       {
#         bool: {
#           should: [
#             { range: { ends_on: { gte: date }}},
#             { bool: { must_not: { exists: { field: :ends_on }}}}
#           ]
#         }
#       }
#     ]
#     search(
#       query: {
#         bool: {
#           filter: {
#             bool: { must: conditions }
#           }
#         }
#       },
#       size: 1,
#     ).first
#   end

#   private

#   def by_query_refresh_strategy
#     Rails.env.test? ? true : false
#   end
# end

