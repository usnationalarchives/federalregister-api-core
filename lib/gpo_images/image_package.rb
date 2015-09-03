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

  private

  def redis
    @redis ||= Redis.new
  end

  def redis_set
    "converted_image_packages:#{date.to_s(:ymd)}"
  end
end
