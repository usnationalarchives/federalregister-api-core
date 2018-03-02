module TableOfContentsRecompiler
  @queue = :reimport

  def self.perform(date)
    ActiveRecord::Base.verify_active_connections!
    
    Content::TableOfContentsCompiler.perform(date)
  end
end
