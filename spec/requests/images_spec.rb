require "spec_helper"

RSpec.describe "Images Endpoint", :type => :request do
  before(:each) { allow_any_instance_of(GraphicStyle).to receive(:url).and_return('http://wwww.example.com') }

  it "renders available styles" do
    GraphicStyle.create!(
      graphic_id: 9999,
      graphic_type: 'GpoGraphic',
      height: 126,
      image_format: 'png',
      image_identifier: 'ep13oc15.011',
      style_name: 'medium',
      width: 572,
    )
    GraphicStyle.create!(
      graphic_id: 9999,
      graphic_type: 'GpoGraphic',
      height: 363,
      image_format: 'png',
      image_identifier: 'ep13oc15.011',
      style_name: 'original',
      width: 1649,
    )

    get '/api/v1/images/EP13OC15.011'
    expect(response.status).to eq(200)
    expect(response.body).to eq({
      "medium": {
        url: "http://wwww.example.com",
        height: 126,
        width: 572,
      },
      "original": {
        url: "http://wwww.example.com",
        height: 363,
        width: 1649,
      }
    }.to_json)
  end

  it "renders a 404 if the image cannot be found" do
    get '/api/v1/images/bad_identifier'
    expect(response.status).to eq(404)
  end

end
