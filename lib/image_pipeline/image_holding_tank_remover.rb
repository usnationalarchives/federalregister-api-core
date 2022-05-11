# This job deletes images from the image holding tank if both production and staging have already downloaded them.
class ImagePipeline::ImageHoldingTankRemover
  include Sidekiq::Worker

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  ENVIRONMENTS_REQUIRING_DOWNLOAD = ['Staging', 'Production']
  def perform(s3_key)
    @s3_key     = s3_key
    @connection = GpoImages::FogAwsConnection.new.connection
    s3_tags     = get_s3_tags
    if ENVIRONMENTS_REQUIRING_DOWNLOAD.all? do |environment| 
        s3_tags["#{environment}DownloadedAt"]
      end
      file = connection.get_object(image_holding_tank_s3_bucket, s3_key)
      file.destroy
    end

  end

  private

  attr_reader :s3_key, :connection

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
