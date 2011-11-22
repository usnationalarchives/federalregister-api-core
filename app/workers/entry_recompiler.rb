module EntryRecompiler
  @queue = :reimport

  def self.perform(type,date)
    Content::EntryCompiler.perform(type,date)
  end
end
