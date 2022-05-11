class ImagePipeline::ImageHoldingTankProcessingEnqueuer

  def self.perform
    GpoImages::FogAwsConnection.
      new.
      connection.
        directories.new(:key => SETTINGS['s3_buckets']['image_holding_tank']).
        files.each do |file|
          ImagePipeline::EnvironmentImageDownloader.perform_async(file.key)
        end
  end

end
