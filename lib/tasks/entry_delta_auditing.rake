namespace :entry_delta_auditing do

  desc "Audit differences between entry delta records and entry change records"
  task :audit => :environment do
    DeltaAuditor.perform
  end

  desc "Resyncs entry_changes table and entry records marked as delta"
  task :resync_index_auditing => :environment do
    ElasticsearchIndexer.resync_index_auditing
  end
end
