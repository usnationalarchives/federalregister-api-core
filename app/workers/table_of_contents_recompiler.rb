module TableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    ActiveRecord::Base.clear_active_connections!
    
    Content::TableOfContentsCompiler.perform(date)
  end
end
