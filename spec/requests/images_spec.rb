require "spec_helper"

RSpec.describe "Images Endpoint", :type => :request do
  before(:each) { allow_any_instance_of(GraphicStyle).to receive(:url).and_return('http://wwww.example.com') }

  it "renders available styles" do
    image = Image.create!(id: 9999, identifier: 'ep13oc15.011', made_public_at: Time.current, source_id: ImageSource::GPO_SFTP.id)
    ImageVariant.create!(
      image_height: 126,
      image_content_type: 'png',
      image_sha: '0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33',
      image_size: 999,
      identifier: 'ep13oc15.011',
      style: 'medium',
      image_width: 572,
    )

    get '/api/v1/images/EP13OC15.011'
    expect(response.status).to eq(200)
    expect(response.body).to eq({
      "medium": {
        content_type: 'png',
        height:       126,
        image_source: 'gpo_sftp',
        sha:          '0beec7b5ea3f0fdbc95d0dd47f3c5bc275da8a33',
        size:         999,
        url:          nil,
        width:        572,
      },
    }.to_json)
  end

  it "renders a 404 if the image is not public" do
    allow_any_instance_of(GraphicStyle).to receive(:public?).and_return(false)
    image = Image.create!(
      id: 9999,
      identifier: 'ep13oc15.011',
      made_public_at: nil,
      source_id: ImageSource::GPO_SFTP.id
    )

    get '/api/v1/images/EP13OC15.011'
    expect(response.status).to eq(404)
  end

  it "renders a 404 if the image cannot be found" do
    get '/api/v1/images/bad_identifier'
    expect(response.status).to eq(404)
  end

end
