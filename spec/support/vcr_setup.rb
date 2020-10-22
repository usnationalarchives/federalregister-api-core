require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :webmock
  c.filter_sensitive_data('<API_KEY>') { Rails.application.secrets[:api_keys][:google_maps_geocode] }

  # comment below to re-record
  c.default_cassette_options = {:record => :new_episodes}
end
