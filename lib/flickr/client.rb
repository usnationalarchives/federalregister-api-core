class Flickr::Client
  attr_reader :connection

  def initialize
    @connection = Faraday.new(:url => 'https://api.flickr.com') do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def get(conditions)
    response = connection.get('/services/rest', build_conditions(conditions))
    response.body
  end

  private

  def build_conditions(conditions)
    default_conditions.deep_merge!(conditions)
  end

  def default_conditions
    {
      :api_key => SECRETS['api_keys']['flickr'],
      :format => 'json',
      :nojsoncallback => 1
      #shared_secret: SECRETS['api_keys']['flickr_secret']
    }
  end
end
