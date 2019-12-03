class FrIndexSingleAgencyCompiler
  @queue = :api_core

  def self.perform(args)
    ActiveRecord::Base.verify_active_connections!
    
    args.symbolize_keys!
    
    agency = Agency.find(args.fetch(:agency_id))
    year = args.fetch(:year)
    path_manager = FileSystemPathManager.new("#{year}-01-01")
    
    FrIndexAgencyCompiler.process_agency_with_docs(year, agency.id)
    CacheUtils.purge_cache("#{path_manager.index_json_dir}/#{agency.slug}.json")
  end
end
