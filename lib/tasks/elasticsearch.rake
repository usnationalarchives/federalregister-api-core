namespace :elasticsearch do
  desc "Create indices for configured indices (if they don't exist)"
  task :create_indices => :environment do
    ElasticsearchIndexer.create_indices
  end

  desc "Update mappings for configured indices"
  task :update_mapping => :environment do
    ElasticsearchIndexer.update_mapping
  end

  desc "Build entry index"
  task :reindex => :environment do
    ElasticsearchIndexer.reindex_entries
  end

  desc "Reindex delta"
  task :reindex_entry_changes => :environment do
    ElasticsearchIndexer.handle_entry_changes
  end
end