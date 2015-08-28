class GpoImages::FogAwsConnection
  delegate :directories, :to => :connection

  private

  def connection
    @connection ||= Fog::Storage.new({
      :provider                 => 'AWS',
      :aws_access_key_id        => secrets["s3"]["username"],
      :aws_secret_access_key    => secrets["s3"]["password"],
      :endpoint => 'https://s3.amazonaws.com/'
    })
  end

  def secrets
    secrets ||= YAML::load_file File.join(Rails.root, 'config', 'secrets.yml')
  end

end
