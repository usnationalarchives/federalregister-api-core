class FrIndexRecompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(year)
    ActiveRecord::Base.clear_active_connections!
    
    FrIndexCompiler.perform(year)
    Agency.all.each do |agency|
      FrIndexAgencyCompiler.process_agency_with_docs(year, agency.id)
    end
  end
end
