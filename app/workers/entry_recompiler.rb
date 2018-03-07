module EntryRecompiler
  @queue = :reimport

  def self.perform(date)
    ActiveRecord::Base.verify_active_connections!
    
    Content::EntryCompiler.perform(date)
  end
end
