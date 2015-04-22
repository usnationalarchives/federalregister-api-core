module TableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    XmlTableOfContentsTransformer.perform(date)
  end
end

