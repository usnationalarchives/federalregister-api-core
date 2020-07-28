class FrIndexSingleAgencyCompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :api_core, :retry => 0

  def perform(args)
    ActiveRecord::Base.clear_active_connections!

    args.symbolize_keys!

    agency = Agency.find(args.fetch(:agency_id))
    year = args.fetch(:year)
    path_manager = FileSystemPathManager.new("#{year}-01-01")

    FrIndexAgencyCompiler.process_agency_with_docs(year, agency.id)

    cached_path = path_manager.index_agency_json_path(agency).gsub(path_manager.data_file_path, '')
    CacheUtils.purge_cache(cached_path)
  end
end
