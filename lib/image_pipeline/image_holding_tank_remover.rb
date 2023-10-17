# This job deletes images from the image holding tank if all the configured
# environments have already downloaded them (usually production and staging)
class ImagePipeline::ImageHoldingTankRemover
  include Sidekiq::Worker

  sidekiq_options :queue => :gpo_image_import, :retry => 0

  def perform(s3_key, force_destroy = nil)
    @s3_key = s3_key
    @connection = GpoImages::FogAwsConnection.new.connection

    if force_destroy
      destroy_s3_object!
      return
    end

    s3_tags = get_s3_tags
    destroy_s3_object! if all_environments_downloaded?(s3_tags)
  end

  private

  attr_reader :s3_key, :connection

  def destroy_s3_object!
    directory = connection.directories.get(image_holding_tank_s3_bucket)
    file = directory.files.get(s3_key)
    file.destroy
  end

  def all_environments_downloaded?(s3_tags)
    environments_requiring_image_download.all? do |env|
      s3_tags["#{env}DownloadedAt"]
    end
  end

  def environments_requiring_image_download
    Settings.app.images.environments_requiring_image_download
  end

  def image_holding_tank_s3_bucket
    Settings.app.aws.s3.buckets.image_holding_tank
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
