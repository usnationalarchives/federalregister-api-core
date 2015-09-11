class GpoImages::FogAwsConnection
  delegate :directories, :to => :connection

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
