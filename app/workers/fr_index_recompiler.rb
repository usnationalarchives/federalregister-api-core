module FrIndexRecompiler
  @queue = :reimport

  def self.perform(year)
    ActiveRecord::Base.clear_active_connections!
    
    FrIndexCompiler.perform(year)
    Agency.all.each do |agency|
      FrIndexAgencyCompiler.process_agency_with_docs(year, agency.id)
    end
  end
end
