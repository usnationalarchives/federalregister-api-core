class PilAgencyLetterJanitor
  include CloudfrontUtils

  def perform
    agency_letters = PilAgencyLetter.
      joins(:public_inspection_document).
      where("#{Date.current.to_s(:iso)} >= publication_date")
    paths_for_expiry = agency_letters.map{|x| "/#{x.file.path}"}

    agency_letters.each{|x| x.destroy!}

    if paths_for_expiry.present?
      # Deleting from S3 doesn't appear to automatically expire Cloudfront.
      create_invalidation(
        Settings.s3_buckets.public_inspection,
        paths_for_expiry
      )
    end
  end

end
