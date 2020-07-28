class PublicInspectionTableOfContentsRecompiler
  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :reimport, :retry => 0

  def perform(date)
    ActiveRecord::Base.clear_active_connections!
    
    TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
    TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)
  end
end
