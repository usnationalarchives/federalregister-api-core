module EntryRecompiler
  @queue = :reimport

  def self.perform(date)
    Content::EntryCompiler.perform(date)
  end
end
