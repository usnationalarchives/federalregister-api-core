require 'ruby-debug'

class GpoImages::FileImporter
  attr_reader :bucket_name, :fog_aws_connection

  def initialize(options={})
    @bucket_name = 'eps.images.fr2.criticaljuncture.org'
    @fog_aws_connection ||= options.fetch(:fog_aws_connection) { GpoImages::FogAwsConnection.new }
  end

  def self.run
    processor = new
    processor.process
  end

  def process
    convert_files(Date.current - 1.day)
    convert_files(Date.current)
  end

  private

  def convert_files(date)
    image_packages_for_date(date).
      reject(&:already_converted?).
      each {|package| GpoImages::FileConverter.new(package.digest, package.date).process}
  end

  def image_packages_for_date(date)
    fog_aws_connection.directories.get(bucket_name, :prefix => date.to_s(:ymd)).files.
      map{|file|file.key}.
      map{|key|GpoImages::ImagePackage.new(date, key)}
  end
end
