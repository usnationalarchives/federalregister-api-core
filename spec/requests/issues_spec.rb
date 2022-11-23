require "spec_helper"

RSpec.describe "Issues Endpoint", :type => :request do

  it "renders a 404 if the issue TOC does not exist" do
    get '/api/v1/issues/2050-01-01.json'
    expect(response.status).to eq(404)
  end

  it "renders a 400 if an invalid date is provided" do
    get '/api/v1/issues/bad_date.json'
    expect(response.status).to eq(400)
  end

  it "renders a 200 if an issue TOC exists" do
    allow_any_instance_of(FileSystemPathManager).to receive(:document_issue_json_toc_path).and_return("spec/fixtures/empty_example_file")
    get '/api/v1/issues/2022-11-23.json'
    expect(response.status).to eq(200)
  end

end
