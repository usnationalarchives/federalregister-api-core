class GpoImages::FogAwsConnection
  delegate :directories, :to => :connection

  def move_directory_files_between_buckets_and_rename(xml_identifier, identifier, source_bucket, destination_bucket)
    directory = directories.get(source_bucket, :prefix => identifier)

    directory.files.each do |file|
      # change the bucket's name to be the same as the xml_identifier
      # now that we've gotten it from the published XML
      filename = file.key.gsub(identifier, URI.encode(xml_identifier))

      # rename the orginal_png style to just original
      filename = filename.include?('original_png') ? filename.gsub('original_png', 'original') : filename

      if file.copy(destination_bucket, filename)
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
