require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :faraday
  c.filter_sensitive_data('<API_KEY>') { Rails.application.secrets[:api_keys][:google_maps_geocode] }
  c.filter_sensitive_data('<API_KEY>') { Rails.application.secrets[:regulations_dot_gov][:v4_api_key] }

  # comment below to re-record
  c.default_cassette_options = {:record => :new_episodes}
  c.allow_http_connections_when_no_cassette = true
end
