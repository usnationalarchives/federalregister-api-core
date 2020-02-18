module PublicInspectionTableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    ActiveRecord::Base.clear_active_connections!
    
    TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
    TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)
  end
end
