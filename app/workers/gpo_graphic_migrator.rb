class GpoGraphicMigrator
  include Sidekiq::Worker
  
  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(image_identifier,made_public_at=UploaderUtils::MIGRATION_MADE_PUBLIC_AT_TIMESTAMP)
    gpo_graphics = GpoGraphic.where(identifier: image_identifier)
    if gpo_graphics.count != 1
      raise "Unexpected number of gpo graphics for #{image_identifier}: #{gpo_graphics.count}"
    end
    
    gpo_graphic = gpo_graphics.first
    if gpo_graphic.graphic_file_name.blank?
      raise "No graphic file exists for image identifier #{image_identifier}"
    end
    image       = Image.find_or_initialize_by(identifier: image_identifier.upcase)

    if gpo_graphic.graphic.file?
      begin
        temp_file = Tempfile.new(['original', '.eps'])
        gpo_graphic.graphic.copy_to_local_file(:original, temp_file.path)
        image.image = temp_file
      ensure
        temp_file.close
      end
    end
    if gpo_graphic.sourced_via_ecfr_dot_gov
      image.source_id = ImageSource::RETIRED_ECFR_DOT_GOV_PDF.id
    else
      image.source_id = ImageSource::GPO_SFTP.id
    end
    if gpo_graphic.public?
      image.made_public_at = made_public_at
      image.image.fog_public = true
    else
      image.made_public_at = nil
      image.image.fog_public = false
    end
    image.save!
  end
end
