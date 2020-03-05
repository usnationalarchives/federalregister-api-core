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
    ElasticsearchIndexer.toggle_on
  end

  task :off => :environment do
    ElasticsearchIndexer.toggle_off
  end

end
