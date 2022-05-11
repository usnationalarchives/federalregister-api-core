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
      Image.includes(:image_variants, image_usages: [:entry]).find_each do |image|
        csv << [
          image.identifier,
          image.image_usages.map(&:document_number).join(','),
          image.image_usages.map(&:entry).map(&:publication_date).join(','),
          image.image_file_name.present?,
          image.image_variants.exists?
        ]
      end
    end
  end

end
