class GpoImages::FogAwsConnection
  delegate :directories, :to => :connection

  def move_directory_files_between_buckets(directory_prefix, source_bucket, destination_bucket)
    directory = directories.get(source_bucket, :prefix => directory_prefix)
    directory.files.each do |file|
      if file.copy(destination_bucket, file.key)
        file.destroy
      else
        Honeybadger.notify(
          :error_class   => "Failure moving file between buckets",
          :error_message => "Failure occurred while copying '#{file.key}' from '#{source_bucket}' to '#{destination_bucket}'."
        )
      end
    end
  end

  private

  def connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => SECRETS["aws"]["access_key_id"],
      :aws_secret_access_key    => SECRETS["aws"]["secret_access_key"],
      :endpoint => 'https://s3.amazonaws.com/',
      :path_style => true
    })
  end

end
