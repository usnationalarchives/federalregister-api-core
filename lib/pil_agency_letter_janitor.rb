class PilAgencyLetterJanitor
  extend Memoist
  include CloudfrontUtils

  def perform
    paths_for_expiry = agency_letters.map{|x| "/#{x.file.path}"}

    agency_letters.each{|x| x.destroy!}

    if paths_for_expiry.present?
      # Deleting from S3 doesn't appear to automatically expire Cloudfront.
      begin
        create_invalidation(
          Settings.s3_buckets.public_inspection,
          paths_for_expiry
        )
      rescue StandardError => e
        Honeybadger.notify(e)
      end
    end
  end

  private

  def agency_letters
    published_document_agency_letters.or(revoked_agency_letters_not_on_pil)
  end
  memoize :agency_letters

  def published_document_agency_letters
    base_scope.
      where("#{Date.current.to_s(:iso)} >= publication_date")
  end

  def revoked_agency_letters_not_on_pil
    base_scope.
      where("publication_date IS NULL").
      where.not(public_inspection_documents: {document_number: current_public_inspection_document_numbers})
  end

  def base_scope
    PilAgencyLetter.joins(:public_inspection_document)
  end

  def current_public_inspection_document_numbers
    PublicInspectionIssue.current.public_inspection_documents.pluck(:document_number)
  end

end
