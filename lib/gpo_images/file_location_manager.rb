class GpoImages::FileLocationManager

  def self.temp_images_path
    File.join(gpo_image_dir, 'temp_image_files')
  end

  def self.temp_zip_files_path
    File.join(gpo_image_dir, 'temp_zip_files')
  end

  def self.compressed_image_bundles_path
    File.join(gpo_image_dir, 'compressed_image_bundles')
  end

  def self.uncompressed_eps_images_path(package_identifer)
    File.join(gpo_image_dir, 'uncompressed_eps_images', package_identifer)
  end

  def self.eps_image_manifest_path
    File.join(gpo_image_dir, 'manifests')
  end

  private

  def self.gpo_image_dir
    File.join(Rails.root, 'data', 'efs', 'gpo_images')
  end
end
