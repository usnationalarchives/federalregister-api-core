class GpoImages::ImagePackage
  attr_reader :date, :digest
  def initialize(date, digest)
    @date = date.is_a?(Date) ? date : Date.parse(date)
    @digest = digest
  end

  def self.s3_bucket_name
    'eps.images.fr2.criticaljuncture.org.test'
  end

  def already_converted?
    redis.sismember(redis_set, digest)
  end

  def mark_as_completed!
    redis.sadd(redis_set, digest)
  end

  def directory
    "tmp/gpo_images/compressed_image_bundles/#{digest}"
  end

  private

  def redis
    Redis.new
  end

  def redis_set
    "converted_files:#{date.to_s(:ymd)}"
  end
end
