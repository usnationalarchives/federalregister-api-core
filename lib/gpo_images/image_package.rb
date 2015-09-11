class GpoImages::ImagePackage
  attr_reader :date, :digest

  def initialize(date, digest)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @digest = digest
  end

  def already_converted?
    redis.sismember(redis_set, digest)
  end

  def mark_as_completed!
    redis.sadd(redis_set, digest)
  end

  def directory
    File.join(GpoImages::FileLocationManager.compressed_image_bundles_path, digest)
  end

  def cleanup_in_progress_files
    if !already_converted?
      path_and_file = File.join(compressed_image_bundles_path, filename_without_date_prefix)
      FileUtils.rm(path_and_file) if File.file?(path_and_file)
      redis.del("images_left_to_convert:#{filename_without_date_prefix}")
    end
  end

  def delete_entire_redis_set
    redis.del(redis_set)
  end

  private

  def filename_without_date_prefix
    num_chars_to_strip = date.to_s(:iso).size + 1
    digest[num_chars_to_strip .. -1]
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
