class MissingImageReportGenerator

  COLUMN_HEADERS = %w(
    image_identifier
    fr_document_numbers
    fr_document_publication_dates
    have_eps_original
    have_any_image
  )
  def self.perform(output_path) #eg /data/test.csv
    CSV.open(output_path, 'wb') do |csv|
      csv << COLUMN_HEADERS
      Image.includes(:image_variants).find_in_batches do |batch|
        image_usages = ImageUsage.
          includes(:entry).
          where(identifier: batch.pluck(:identifier)).
          group_by(&:identifier)
        batch.each do |image|
          usages = image_usages[image.identifier] || []
          csv << [
            image.identifier,
            usages.map(&:document_number).join(','),
            usages.map(&:entry).map(&:publication_date).join(','),
            image.image_file_name.present?,
            image.image_variants.present?
          ]
        end
      end
    end
  end

end
