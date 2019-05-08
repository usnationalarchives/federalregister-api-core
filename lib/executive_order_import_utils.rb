module ExecutiveOrderImportUtils

  def record_job_status(file_identifier, status)
    $redis.set("admin:executive_orders:#{file_identifier}", status)
  end

  def job_finished?(file_identifier)
    $redis.get("admin:executive_orders:#{file_identifier}") == 'complete'
  end

  def job_failed?(file_identifier)
    $redis.get("admin:executive_orders:#{file_identifier}") == 'failed'
  end
end
