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

  desc "Copy index from the other environment"
  task :copy_primary_index => :environment do
    primary = Settings.container.deployment_environment == 'green' ? 'blue' : 'green'

    $entry_repository.copy_index(
      source_index: ['fr-entries', Rails.env, primary].join('-'),
      destination_index: ['fr-entries', Rails.env, Settings.container.deployment_environment].join('-')
    )
  end

  desc "Ensure the PI index alias is in place since we use the alias instead of the actual index in the repository's configuration."
  task :assign_pi_index_alias => :environment do
    ElasticsearchIndexer.assign_pi_index_alias
  end

  desc "Clear entry changes"
  task :delete_entry_changes => :environment do
    ElasticsearchIndexer.delete_entry_changes
  end

  desc "Launch a machine learning model into the Opensearch cluster if it does not yet exist"
  task :launch_ml_model => :environment do
    OpenSearchMlModelRegistrar.perform
  end

  desc "Create an ingest pipeline that chunks document full text and generates vector embeddings"
  task :create_chunking_ingest_pipeline => :environment do
    OpenSearchIngestPipelineRegistrar.create_chunking_ingest_pipeline!(OpenSearchMlModelRegistrar.model_id)
  end

end
