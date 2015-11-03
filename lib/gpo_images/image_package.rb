class GpoImages::ImagePackage
  attr_reader :date, :digest

  def initialize(date, bucketed_zip_filename)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @digest = bucketed_zip_filename
  end

  def already_converted?
    redis.sismember(redis_set, digest)
  end

  def mark_as_complete!
    redis.sadd(redis_set, digest)
  end

  def cleanup_package
    file_path = File.join(compressed_image_bundles_path, package_name)
    FileUtils.rm(file_path) if File.file?(file_path)

    redis.del("images_left_to_convert:#{package_name}")
  end

  def delete_redis_set
    redis.del(redis_set)
  end

  private

  def package_name
    @package_name = digest.split('/').last
  end

  def compressed_image_bundles_path
    GpoImages::FileLocationManager.compressed_image_bundles_path
  end

  def redis
    @redis ||= Redis.new
  end

  def redis_set
    "converted_image_packages:#{date.to_s(:ymd)}"
  end
end
