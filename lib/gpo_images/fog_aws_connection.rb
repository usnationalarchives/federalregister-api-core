class GpoImages::FogAwsConnection
  delegate :directories, :to => :connection

  MAX_RETRIES = 1
  def move_directory_files_between_buckets_and_rename(xml_identifier, identifier, source_bucket, destination_bucket, options={})
    directory = directories.get(source_bucket, :prefix => identifier)

    directory.files.each do |file|
      if options[:sourced_via_ecfr_dot_gov]
        # ECFR Renderer expects image identifiers to be uppercase and S3 is case-sensitive
        # example: er30no17.024/large.png => ER30NO17.024/large.png
        delimeter = '/'
        filename = file.
          key.
          split(delimeter).
          each_with_index.map{|x, index| index == 0 ? x.upcase : x }.
          join(delimeter)
      else
        # change the object's name to be the same as the xml_identifier
        # now that we've gotten it from the published XML
        filename = file.key.gsub(identifier, Addressable::URI.encode(xml_identifier))
      end

      retry_count = 0
      begin
        if file.copy(destination_bucket, filename)
          file.destroy
        else
          Honeybadger.notify(
            :error_class   => "Failure moving file between buckets",
            :error_message => "Failure occurred while copying '#{file.key}' from '#{source_bucket}' to '#{destination_bucket}'."
          )
        end
      rescue Excon::Error::InternalServerError => error
        if retry_count < MAX_RETRIES
          sleep 2
          retry_count += 1
          retry
        else
          Honeybadger.notify(error.message)
        end
      end
    end
  end

  private

  def connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => Rails.application.secrets[:aws][:access_key_id],
      :aws_secret_access_key    => Rails.application.secrets[:aws][:secret_access_key],
      :endpoint => 'https://s3.amazonaws.com/',
      :path_style => true
    })
  end

end
