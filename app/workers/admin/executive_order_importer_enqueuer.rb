class Admin::ExecutiveOrderImporterEnqueuer
  extend ExecutiveOrderImportUtils
  @queue = :api_core

  def self.perform(file_path, file_identifier)
    begin
      Content::ExecutiveOrderImporter.perform(file_path)
      SphinxIndexer.rebuild_delta_and_purge_core(Entry)
      CacheUtils.purge_cache(".*")
      record_job_status(file_identifier, 'complete')
    rescue StandardError => e
      record_job_status(file_identifier, 'failed')
      raise e
    end
  end

end
