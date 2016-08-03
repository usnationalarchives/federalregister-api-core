module TableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    Content::TableOfContentsCompiler.perform(date)
  end
end
