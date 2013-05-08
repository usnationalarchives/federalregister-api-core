module SphinxIndexer
  def self.perform(*index_names)
    system("/usr/local/bin/indexer -c #{Rails.root.join('config', "#{Rails.env}.sphinx.conf")} #{index_names.join(' ')} --rotate")
  end
end
