class Admin::ExecutiveOrderImporterEnqueuer
  include ExecutiveOrderImportUtils

  include Sidekiq::Worker
  include Sidekiq::Throttled::Worker

  sidekiq_options :queue => :api_core, :retry => 0

  def perform(file_path, file_identifier)
    begin
      Content::ExecutiveOrderImporter.new.perform(file_path, Settings.only_log_on_eo_import)
      ElasticsearchIndexer.handle_entry_changes
      CacheUtils.purge_cache(".*")
      record_job_status(file_identifier, 'complete')
    rescue StandardError => e
      record_job_status(file_identifier, 'failed')
      raise e
    end
  end

end
