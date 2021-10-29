require "spec_helper"

RSpec.describe "Entries API", :type => :request do

  it "Basic search query" do
    agency = Factory(:agency)
    agency_name = Factory(:agency_name, agency: agency)
    entry = Factory(
      :entry,
      significant: 0,
      title: 'goat',
      publication_date: Date.current,
      agencies: [agency],
      agency_names: [agency_name],
      granule_class: 'PRESDOCU',
      raw_text_updated_at: Time.current
    )
    ElasticsearchIndexer.reindex_entries(recreate_index: true)

    get "/api/v1/documents.json?per_page=20&conditions[term]=goat"
    json_response = JSON.parse(response.body)

    expect(json_response).to include(
      'count' => 1
    )
    expect(json_response.fetch('results').first).to include(
      'html_url' => "http://www.fr2.local:8081/documents/#{entry.publication_date.year}/#{entry.publication_date.month}/#{entry.publication_date.day}/#{entry.document_number}/#{entry.slug}",
      'pdf_url'  => "https://www.govinfo.gov/content/pkg/FR-#{entry.publication_date.to_s(:iso)}/pdf/#{entry.document_number}.pdf",
      'title'    => 'goat',
      'type'     => 'Presidential Document',
      'excerpts' => "<span class=\"match\">goat</span>"
    )
  end

end
