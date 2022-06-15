# This job deletes images from the image holding tank if both production and staging have already downloaded them.
class ImagePipeline::ImageHoldingTankRemover
  include Sidekiq::Worker

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(s3_key)
    @s3_key     = s3_key
    @connection = GpoImages::FogAwsConnection.new.connection
    s3_tags     = get_s3_tags
    if environments_requiring_image_download.all? do |environment| 
        s3_tags["#{environment}DownloadedAt"]
    end
      destroy_s3_object!
    end

  end

  private

  attr_reader :s3_key, :connection

  def destroy_s3_object!
    directory = connection.directories.get(image_holding_tank_s3_bucket)
    file      = directory.files.get(s3_key)
    file.destroy
  end

  def environments_requiring_image_download
    SETTINGS['cron']['images']['environments_requiring_image_download']
  end

  def image_holding_tank_s3_bucket
    SETTINGS['s3_buckets']['image_holding_tank']
  end

  def get_s3_tags
    begin
      response = connection.get_object_tagging(
        image_holding_tank_s3_bucket,
        s3_key
      )
    rescue Excon::Error::NotFound
      return {} # return empty hash so delete operation doesn't execute
    end
    response.body.fetch('ObjectTagging')
  end

end
