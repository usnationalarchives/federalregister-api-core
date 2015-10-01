class GpoImages::FileImporter
  attr_reader :date, :fog_aws_connection

  def initialize(date, options={})
    @date = date.is_a?(String) ? Date.parse(date) : date
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
  end

  def self.run(date)
    new(date).process
  end

  def self.force_convert(date)
    new(date).force_convert
  end

  def process
    convert_files
  end

  def force_convert
    cleanup_old_packages
    convert_files
  end

  private

  def bucket_name
    SETTINGS["s3_buckets"]["zipped_eps_images"]
  end

  def cleanup_old_packages
    image_packages = image_packages_for_date(date)
    image_packages.each do |image_package|
      image_package.cleanup_in_progress_files
    end
    image_packages.first.delete_entire_redis_set if image_packages.present?
  end

  def convert_files
    image_packages_for_date(date).
      reject(&:already_converted?).
      each {|package| GpoImages::FileConverter.new(package.digest, package.date).process}
  end

  def image_packages_for_date(date)
    fog_aws_connection.directories.get(bucket_name, :prefix => date.to_s(:ymd)).files.
      map{|file| file.key}.
      select{|key| File.extname(key) == '.zip'}.
      map{|key|GpoImages::ImagePackage.new(date, key)}
  end
end
