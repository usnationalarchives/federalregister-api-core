class GpoImages::FileLocationManager

  def self.temp_images_path
    File.join(Rails.root, 'tmp', 'gpo_images', 'temp_image_files')
  end

  def self.temp_zip_files_path
    File.join(Rails.root, 'tmp', 'gpo_images', 'temp_zip_files')
  end

  def self.compressed_image_bundles_path
    File.join(Rails.root, 'tmp', 'gpo_images', 'compressed_image_bundles')
  end

  def self.uncompressed_eps_images_path(package_identifer)
    File.join(Rails.root, 'tmp', 'gpo_images', 'uncompressed_eps_images', package_identifer)
  end

  def self.eps_image_manifest_path
    File.join(Rails.root, 'data', 'gpo_images')
  end
end
