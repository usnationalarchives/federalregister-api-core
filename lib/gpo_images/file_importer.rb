class GpoImages::FileImporter
  attr_reader :bucket_name, :fog_aws_connection, :custom_date

  def initialize(options={})
    @bucket_name = SETTINGS["zipped_eps_images_s3_bucket"]
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    @custom_date = Date.parse ENV['DATE'] if ENV['DATE']
  end

  def self.run
    new.process
  end

  def self.force_eps_convert
    new.force_eps_convert
  end

  def process
    if custom_date
      convert_files(custom_date)
    else
      convert_files(Date.current - 1.day)
      convert_files(Date.current)
    end
  end

  def force_eps_convert
    raise "A valid custom date must be supplied." if custom_date.nil?
    image_packages = image_packages_for_date(custom_date)
    image_packages.each do |image_package|
      image_package.cleanup_in_progress_files
    end
    image_packages.first.delete_entire_redis_set
  end

  private

  def convert_files(date)
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
