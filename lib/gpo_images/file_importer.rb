require 'ruby-debug'

class GpoImages::FileImporter
  attr_reader :bucket_name, :fog_aws_connection, :custom_date

  def initialize(options={})
    @bucket_name = SETTINGS["zipped_eps_images_s3_bucket"]#'eps.images.fr2.criticaljuncture.org' #This should be eps.images.federalregister.gov
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
    if options[:custom_date]
      @custom_date = options[:custom_date].is_a?(Date) ? options[:custom_date] : Date.parse(options[:custom_date])
    end
  end

  def self.run(options={})
    new(options).process
  end

  def process
    if custom_date
      convert_files(custom_date)
    else
      convert_files(Date.current - 1.day)
      convert_files(Date.current)
    end
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
