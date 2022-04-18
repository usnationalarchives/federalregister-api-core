require "spec_helper"

RSpec.describe "Images Endpoint", :type => :request do
  before(:each) { allow_any_instance_of(GraphicStyle).to receive(:url).and_return('http://wwww.example.com') }

  it "renders available styles" do
    allow_any_instance_of(GraphicStyle).to receive(:public?).and_return('truthy')
    GpoGraphic.create!(id: 9999, identifier: 'ep13oc15.011')
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
      style_name: 'original_png',
      width: 1649,
    )
    GraphicStyle.create!(
      graphic_id: 9999,
      graphic_type: 'GpoGraphic',
      height: 363,
      image_format: 'eps',
      image_identifier: 'ep13oc15.011',
      style_name: 'original',
      width: 1649,
    )

    get '/api/v1/images/EP13OC15.011'
    expect(response.status).to eq(200)
    expect(response.body).to eq({
      "medium": {
        height: 126,
        image_format: "png",
        image_source: "GPO SFTP",
        url: "http://wwww.example.com",
        width: 572,
      },
      "original_png": {
        height: 363,
        image_format: "png",
        image_source: "GPO SFTP",
        url: "http://wwww.example.com",
        width: 1649,
      },
      "original": {
        height: 363,
        image_format: "eps",
        image_source: "GPO SFTP",
        url: "http://wwww.example.com",
        width: 1649,
      }
    }.to_json)
  end

  it "renders a 404 if the image is not public" do
    allow_any_instance_of(GraphicStyle).to receive(:public?).and_return(false)
    GraphicStyle.create!(
      graphic_id: 9999,
      graphic_type: 'GpoGraphic',
      height: 126,
      image_format: 'png',
      image_identifier: 'ep13oc15.011',
      style_name: 'medium',
      width: 572,
    )

    get '/api/v1/images/EP13OC15.011'
    expect(response.status).to eq(404)
  end

  it "renders a 404 if the image cannot be found" do
    get '/api/v1/images/bad_identifier'
    expect(response.status).to eq(404)
  end

end
