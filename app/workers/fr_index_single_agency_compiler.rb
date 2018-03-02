class FrIndexSingleAgencyCompiler
  @queue = :api_core

  def self.perform(args)
    ActiveRecord::Base.verify_active_connections!
    
    args.symbolize_keys!

    FrIndexAgencyCompiler.process_agency_with_docs(
      args.fetch(:year),
      args.fetch(:agency_id)
    )

    CacheUtils.purge_cache("/index/#{args.fetch(:year)}/#{args.fetch(:slug)}")
  end
end
