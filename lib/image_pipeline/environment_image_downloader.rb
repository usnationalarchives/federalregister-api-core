# This job downloads EPS files from the image holding tank, saves the original EPS image to a long-lived S3 bucket and generates the image variants, saving them to S3 as well.
class ImagePipeline::EnvironmentImageDownloader
  extend Memoist
  include Sidekiq::Worker
  include GpoImages::ImageIdentifierNormalizer

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(s3_key)
    @s3_key = s3_key
    @connection = GpoImages::FogAwsConnection.new.connection
    if already_downloaded?
      return
    elsif s3_file_already_exists?
      # This scenario is unexpected, but could occur if OFR is uploading a replacement image
      Honeybadger.notify("#{s3_key} already exists")
      return
    elsif image_record_already_exists?
      # This scenario is unexpected
      Honeybadger.notify("#{s3_key} already_exists in the database")
      return
    end

    begin
      response = connection.get_object(image_holding_tank_s3_bucket, s3_key)
      temp_file = File.new(s3_key, "w")
      temp_file.binmode
      temp_file.puts(response.body)
      temp_file.rewind
      
      # Save image to S3
      image = Image.find_or_initialize_by(
        identifier: normalized_image_identifier,
      )
      image.assign_attributes(
        image:      temp_file,
        source_id:  ImageSource::GPO_SFTP.id
      )
      if image.image_usages.present?
        image.image.fog_public = true
      else
        image.image.fog_public = false
      end
      image.save!
    rescue Excon::Error::NotFound => e
      raise "Object not found on S3: #{} #{s3_key}" #DOC: Improve error message here
    ensure
      if File.exists? temp_file.path
        File.delete(temp_file.path) 
      end
    end

    # Update S3 object tags
    s3_tags = get_s3_tags
    # There is a possible race condition here--eg PROD fetches tags, staging updates tags to indicate it's downloaded the file, and then PROD updates tags and does not include the staging downloaded at tag.  In this case, staging will simply re-download.
    put_s3_tags(
      s3_tags.merge(downloaded_at_tag => Time.current.to_s(:iso))
    )

    # Enqueue job to check on removing from holding tank
    ImagePipeline::ImageHoldingTankRemover.perform_in(10.minutes, s3_key)
  end

  private

  attr_reader :s3_key, :connection

  def normalized_image_identifier
    normalize_image_identifier(s3_key)
  end
  memoize :normalize_image_identifier

  def image_holding_tank_s3_bucket
    SETTINGS['s3_buckets']['image_holding_tank']
  end

  def already_downloaded?
    #TODO: Possibly handle situation when image doesn't exist at all so we don't hard fail
    get_s3_tags[downloaded_at_tag]
  end

  def image_record_already_exists?
    Image.find_by(identifier: normalized_image_identifier)
  end

  def s3_file_already_exists?
    directory = connection.directories.get(SETTINGS['s3_buckets']['original_images'])
    directory.files.get(normalized_image_identifier)
  end

  def get_s3_tags
    response = connection.get_object_tagging(
      image_holding_tank_s3_bucket,
      s3_key
    )
    response.body.fetch('ObjectTagging')
  end

  def put_s3_tags(tags)
    connection.put_object_tagging(
      image_holding_tank_s3_bucket,
      s3_key,
      tags
    )
  end

  def downloaded_at_tag
    "#{Rails.env.titleize}DownloadedAt"
  end

end
