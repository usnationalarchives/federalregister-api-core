require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr_cassettes'
  c.hook_into :fakeweb
  c.filter_sensitive_data('<API_KEY>') { ENV['google_maps_api_key'] }

  # comment below to re-record
  # c.default_cassette_options = {:record => :all}
end
