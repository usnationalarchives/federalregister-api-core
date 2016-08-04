module PublicInspectionTableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    TableOfContentsTransformer::PublicInspection::RegularFiling.perform(date)
    TableOfContentsTransformer::PublicInspection::SpecialFiling.perform(date)
  end
end
