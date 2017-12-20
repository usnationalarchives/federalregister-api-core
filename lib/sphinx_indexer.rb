module SphinxIndexer
  def self.perform(*index_names)
    config = ThinkingSphinx::Configuration.instance
    system("/usr/local/bin/indexer -c #{config.config_file} #{index_names.join(' ')} --rotate")
  end
end
