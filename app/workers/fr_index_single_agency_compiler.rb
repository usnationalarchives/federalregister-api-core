class FrIndexSingleAgencyCompiler
  @queue = :default

  def self.perform(args)
    args.symbolize_keys!

    FrIndexAgencyCompiler.process_agency_with_docs(
      args.fetch(:year),
      args.fetch(:agency_id)
    )

    CacheUtils::Client.instance.purge("/index/#{args.fetch(:year)}/#{args.fetch(:slug)}")
  end
end
