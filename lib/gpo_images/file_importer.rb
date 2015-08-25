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
    unconverted_filename_list = s3_filenames_for_date(date) - already_converted_filenames(date)
    unconverted_filename_list.each{|filename| GpoImages::FileConverter.new(filename, date).process}
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

  def s3_filenames_for_date(date)
    fog_aws_connection.directories.get(bucket_name, :prefix => date.to_s(:ymd)).files.
      map{|file|file.key}
  end

  def redis_set_key(date)
    "converted_files:#{date.to_s(:ymd)}"
  end

  def already_converted_filenames(date)
    Redis.new.smembers(redis_set_key(date))
  end

end
