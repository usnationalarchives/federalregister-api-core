namespace :elasticsearch do
  desc "Build entry index"
  task :reindex => :environment do
    ElasticsearchIndexer.reindex_entries
  end

  desc "Reindex delta"
  task :reindex_entry_changes => :environment do
    ElasticsearchIndexer.handle_entry_changes
  end

  task :on => :environment do
    `touch #{ElasticsearchIndexer::ES_TEMP_FILE}`
  end

  task :off => :environment do
    if ElasticsearchIndexer.es_enabled?
      `rm #{ElasticsearchIndexer::ES_TEMP_FILE}`
    end
  end

end
