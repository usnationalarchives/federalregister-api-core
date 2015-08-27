require 'ruby-debug'

class GpoImages::FileImporter
  attr_reader :bucket_name

  def initialize
    @bucket_name = 'eps.images.fr2.criticaljuncture.org.test'
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

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

  def fog_aws_connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => secrets["s3"]["username"],
      :aws_secret_access_key    => secrets["s3"]["password"],
      :endpoint => 'https://s3.amazonaws.com/'
    })
  end

  def image_packages_for_date(date)
    fog_aws_connection.directories.get(bucket_name, :prefix => date.to_s(:ymd)).files.
      map{|file|file.key}.
      map{|key|GpoImages::ImagePackage.new(date, key)} #Added key
  end
end
