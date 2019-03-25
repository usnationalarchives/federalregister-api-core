module ExecutiveOrderImportUtils

  def record_job_status(file_identifier, job_is_finished)
    $redis.set("admin:executive_orders:#{file_identifier}", job_is_finished)
  end

  def job_is_finished?(file_identifier)
    $redis.get("admin:executive_orders:#{file_identifier}") == 'true'
  end

end
