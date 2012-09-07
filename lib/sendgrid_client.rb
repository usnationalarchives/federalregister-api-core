class SendgridClient
  include HTTParty
  base_uri 'https://sendgrid.com'
  format :json
  
  config_path = File.join(Rails.root, 'config', 'sendgrid.yml')
  config = File.exists?(config_path) ? File.open(config_path) { |yf| YAML::load( yf ) } : {}

  default_params :api_user => config['username'], :api_key => config['password']

  def remove_from_bounce_list(email)
    self.class.get('/api/bounces.delete.json', :query => {:email => email}).parsed_response
  end
end
