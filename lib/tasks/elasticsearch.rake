namespace :elasticsearch do
  desc "Create indices for configured indices (if they don't exist)"
  task :create_indices => :environment do
    ElasticsearchIndexer.create_indices
  end

  desc "Update mappings for configured indices"
  task :update_mapping => :environment do
    ElasticsearchIndexer.update_mapping
  end

  desc "Delete and recreate entry deployment environment index"
  task :reindex => :environment do
    # Pass DEPLOYMENT_ENVIRONMENT env to change affected index
    ElasticsearchIndexer.reindex_entries(recreate_index: true)
  end

  desc "Reindex delta"
  task :reindex_entry_changes => :environment do
    ElasticsearchIndexer.handle_entry_changes
  end
end
