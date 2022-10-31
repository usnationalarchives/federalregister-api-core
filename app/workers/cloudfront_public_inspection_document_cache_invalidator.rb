class CloudfrontPublicInspectionDocumentCacheInvalidator
  include Sidekiq::Worker
  include CloudfrontUtils
  sidekiq_options :queue => :public_inspection

  def perform(document_numbers)
    create_invalidation(
      Settings.s3_buckets.public_inspection,
      document_numbers.map{|document_number| "/#{document_number}.pdf" }
    )
  end

end
