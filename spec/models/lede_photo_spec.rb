require 'spec_helper'

describe LedePhoto do

  it "returns the correct attachment url" do
    attachment = File.new(Rails.root + 'spec/fixtures/empty_example_file')
    result = LedePhoto.new(photo: attachment).photo.url
    host = "https://#{SETTINGS['s3_host_aliases']['lede_photos']}"
    expect(result).to start_with(host)
  end

end
