class CloudfrontPublicInspectionDocumentCacheInvalidator
  include Sidekiq::Worker
  include CloudfrontUtils
  sidekiq_options :queue => :public_inspection

  def perform(document_numbers)
    create_invalidation(
      Settings.app.aws.s3.buckets.public_inspection,
      document_numbers.map{|document_number| "/#{document_number}.pdf" }
    )
  end

end
